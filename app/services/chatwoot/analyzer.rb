module Chatwoot
  class Analyzer
    KEYWORDS = {
      "price" => ["caro", "precio", "costo", "cuanto", "¿cuánto?", "presupuesto"],
      "delay" => ["tarda", "demora", "tiempo", "cuando", "cuándo", "espera", "días", "lento"],
      "design" => ["diseño", "logo", "archivo", "formato", "pdf", "jpg", "armar"],
      "payment" => ["pago", "tarjeta", "transferencia", "efectivo", "cuotas"],
      "location" => ["donde", "dónde", "ubicación", "dirección", "envio", "envío"]
    }

    def analyze(conversations)
      puts "Analyzing #{conversations.count} conversations for keywords..."
      
      conversations.each do |conversation|
        analyze_single(conversation)
      end
    end

    private

    def analyze_single(conversation)
      messages = conversation.raw_data.dig('messages') || []
      return if messages.empty?

      # Combine all customer messages
      customer_text = ""
      
      messages.each do |msg|
        # Check if message is from the contact (not the agent/user)
        # In Chatwoot: sender_type 'User' is agent. 'Contact' is customer.
        if msg['sender_type'] != 'User'
          content = msg['content']
          customer_text += " " + content.downcase if content.present?
        end
      end

      analysis_result = {
        "counts" => {},
        "snippets" => {}
      }

      KEYWORDS.each do |category, terms|
        hit = false
        terms.each do |term|
          if customer_text.include?(term)
            unless hit
              analysis_result["counts"][category] = 1 # Just marking presence per conversation
              hit = true
              
              # Store a snippet logic could be complex (finding the exact message)
              # For now, let's just mark it as found. 
              # If we want detailed snippets later we can parse better.
            end
          end
        end
      end

      # Remove empty keys if any
      # analysis_result["counts"].select! { |_, v| v > 0 }

      # Perform update only if there's something relevant or to clear previous state
      # We merge with existing analysis or overwrite? let's overwrite to be fresh.
      
      # We want to match the structure expected by the dashboard if any. 
      # The python script calculated global stats. Here we are storing per-conversation stats.
      # The dashboard can aggregate them.
      
      conversation.update(analysis: analysis_result)
    end
  end
end
