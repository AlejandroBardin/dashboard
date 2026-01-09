module Chatwoot
  class GlobalAuditor
    def self.run
      new.run
    end

    def initialize
      @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
      @model = "gpt-4o-mini"
    end

    def run
      # 1. Fetch last 100 aggregated analyses
      conversations = Conversation.where.not(analysis: nil).order(created_at: :desc).limit(100)

      return if conversations.empty?

      # 2. Prepare aggregated data for context
      # We map only essential fields to save tokens
      aggregated_data = conversations.map do |c|
        a = c.analysis
        {
          id: c.id,
          rating: a.dig("bot_audit", "rating"),
          friction: a.dig("bot_audit", "friction_points"),
          response_rating: a.dig("agent_performance", "response_time_rating"),
          loss_reason: a.dig("sales_outcome", "loss_reason"),
          design_need: a.dig("client_metrics", "design_need"),
          anger: a.dig("post_sales_analysis", "customer_anger")
        }
      end.to_json

      # 3. Construct Prompt
      prompt = <<~PROMPT
        Eres el Auditor Jefe de "La Gráfica". Analiza estos #{conversations.count} reportes de conversaciones recientes:

        DATA:
        #{aggregated_data}

        TU TAREA:
        Redacta un "Diagnóstico Maestro del Auditor" en formato HTML (sin markdown, usar <p>, <strong>, <ul>).
        El reporte debe tener EXACTAMENTE estos 3 párrafos (ni uno más, ni uno menos):

        <p><strong>1. Cuello de Botella (Modelo de Negocio):</strong> Analiza si estamos perdiendo ventas por falta de diseño (design_need alto) o precios. Sé directo.</p>

        <p><strong>2. Desempeño del Bot (Tecnología):</strong> Evalúa "rating" y "friction_points". ¿El bot es tosco? ¿Bloquea ventas? ¿Es empático?</p>

        <p><strong>3. Factor Humano & Post-Venta:</strong> Evalúa "response_rating" y "anger". ¿Estamos tardando mucho? ¿Hay clientes enojados esperando entregas?</p>

        Tono: Ejecutivo, crítico, constructivo. No saludes. Ve al grano.
      PROMPT

      # 4. Call OpenAI
      begin
        response = @client.chat(
          parameters: {
            model: @model,
            messages: [ { role: "user", content: prompt } ]
          }
        )

        report_content = response.dig("choices", 0, "message", "content")

        # 5. Save to Cache (Expire in 24 hours) AND File (for Dev Persistence)
        Rails.cache.write("global_audit_report", report_content, expires_in: 24.hours)

        # Backup for MemoryStore environments (Development)
        File.write(Rails.root.join("tmp", "global_audit_report.html"), report_content)

        puts "Global Auditor Report Generated Successfully."

      rescue StandardError => e
        puts "Global Auditor Failed: #{e.message}"
      end
    end
  end
end
