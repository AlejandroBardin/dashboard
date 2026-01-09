require 'openai'

module Chatwoot
  class AiAnalyzer
    def initialize
      @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
      @model = "gpt-4o-mini"
    end

    def analyze(conversations)
      puts "Analyzing #{conversations.count} conversations with OpenAI (#{@model})..."
      
      conversations.each do |conversation|
        analyze_single(conversation)
      end
    end

    private

    def analyze_single(conversation)
      messages = conversation.raw_data.dig('messages') || []
      return if messages.empty?

      # Calculate Performance Metrics
      metrics = calculate_metrics(messages)

      # Format transcript with Timestamps and Sender Name
      # Chatwoot returns messages newest first by default in some endpoints, but we reversed them in previous logic.
      # Let's ensure chronological order (Oldest -> Newest)
      sorted_messages = messages.sort_by { |m| m['created_at'] }
      
      transcript = sorted_messages.map do |msg|
        # Use message_type: 0 (Incoming/Client), 1 (Outgoing/Agent)
        is_agent = msg['message_type'] == 1
        
        sender_name = if is_agent
                        msg.dig('sender', 'name') || "Bot/Agente"
                      else
                        msg.dig('sender', 'name') || "Cliente"
                      end
        
        time_str = Time.at(msg['created_at']).in_time_zone('America/Argentina/Buenos_Aires').strftime("[%d/%m %H:%M]")
        content = msg['content']
        
        "#{time_str} #{sender_name}: #{content}"
      end.join("\n")

      prompt = construct_prompt(transcript, conversation.external_id, metrics)

      begin
        response = @client.chat(
          parameters: {
            model: @model,
            messages: [{ role: "user", content: prompt }],
            response_format: { type: "json_object" }
          }
        )
        
        result_json = response.dig("choices", 0, "message", "content")
        parsed_result = JSON.parse(result_json)
        
        # Merge with existing analysis or overwrite
        conversation.update(analysis: parsed_result)
        puts "  Analyzed conversation #{conversation.external_id}: Success"
        
      rescue StandardError => e
        puts "  Failed to analyze conversation #{conversation.external_id}: #{e.message}"
      end
    end

    def calculate_metrics(messages)
      # Sort by time
      sorted = messages.sort_by { |m| m['created_at'] }
      
      response_times = []
      last_customer_msg_time = nil

      sorted.each do |msg|
        is_agent = msg['message_type'] == 1 # 1 = Outgoing
        
        if !is_agent
          # Customer message
          last_customer_msg_time = msg['created_at']
        elsif last_customer_msg_time
          # Agent response to a pending customer message
          diff_minutes = (msg['created_at'] - last_customer_msg_time) / 60.0
          response_times << diff_minutes
          last_customer_msg_time = nil # Reset
        end
      end

      if response_times.any?
        {
          avg_response_time: (response_times.sum / response_times.size).round(1),
          max_response_time: response_times.max.round(1),
          response_count: response_times.size
        }
      else
        { avg_response_time: 0, max_response_time: 0, response_count: 0 }
      end
    end

    def construct_prompt(transcript, conversation_id, metrics)
      <<~PROMPT
        Eres un Consultor Estratégico y Analista de Datos para "La Gráfica". Tu función es auditar logs de conversaciones de WhatsApp.

        TU OBJETIVO:
        Analizar el chat proporcionado y devolver un JSON con las métricas tácticas (ventas) y operativas (desempeño del agente).

        === CONTEXTO OPERATIVO ===
        - Tiempo Promedio de Respuesta: #{metrics[:avg_response_time]} minutos
        - Tiempo Máximo de Espera: #{metrics[:max_response_time]} minutos
        - Cantidad de Respuestas: #{metrics[:response_count]}

        === INPUT ===
        ID Conversación: #{conversation_id}
        TRANSCRIPCIÓN:
        #{transcript}

        === OUTPUT FORMAT (JSON) ===
        Debes responder EXCLUSIVAMENTE con un objeto JSON válido con la siguiente estructura:

        {
          "client_metrics": {
            "objections": ["Precio", "Cantidad", "Urgencia", "Diseño", "Calidad", "Confianza", "Medios de pago", "Entrega", "Ninguna"],
            "temperature": 1-10,
            "emotion": 1-10,
            "purchase_intention": 1-10,
            "real_urgency": 1-10,
            "design_need": 1-10,
            "loss_risk": 1-10
          },
          "bot_audit": {
            "rating": 1-10,
            "friction_points": {
              "dead_ends": boolean,
              "contextual_deafness": boolean,
              "lack_of_empathy": boolean
            },
            "success": boolean,
            "feedback": "Breve explicación de qué se hizo mal o bien, citando patrones."
          },
          "agent_performance": {
             "response_time_rating": "1-10 (Evalúa si los tiempos fueron aceptables para la urgencia del cliente)",
             "resolution": "Did the agent solve the issue? boolean",
             "delivery_promise": "Did the agent promise a date? boolean"
          },
          "sales_outcome": {
             "result": "won" | "lost" | "in_progress",
             "loss_reason": "Categoría principal (ej: Precio, Error Bot, Sin Diseño, Falta Stock, Ghosting, Envíos, etc). Null si won/in_progress.",
             "loss_explanation": "Insight de 1 frase del por qué de la pérdida.",
             "factors": {
                "price": boolean,
                "design": boolean,
                "stock": boolean,
                "timing": boolean,
                "bot_error": boolean
             }
          }
        }

        === CRITERIOS DE EVALUACIÓN ===
        
        1. OBJECIONES: Identifica claramente las barreras.
        2. TEMPERATURA (1-10): 1-3 Frío, 4-7 Medio, 8-10 Cierre.
        3. VENTAS (Deep Dive):
           - Si la venta se perdió, DEBES identificar la causa raíz.
           - "Bot Error": Si el bot se bucleó o no entendió.
           - "Ghosting": Si el cliente dejó de contestar sin decir nada.
        
        AUDITORÍA DEL BOT/AGENTE:
        - Evalúa bloqueos, sordera contextual y falta de empatía.
        - Usa los Tiempos de Respuesta provistos para calificar la agilidad.
        - PENALIZACIÓN SEVERA:
          * Si el bot entra en bucle repetitivo -> Rating MAX 3.
          * Si el cliente pide humano y el bot sigue -> Rating MAX 2. 
          * Si se pierde una venta por respuesta tardía o errónea -> Rating MAX 4.
        - Califica de 1 a 10 (Sé muy crítico).
      PROMPT
    end
  end
end
