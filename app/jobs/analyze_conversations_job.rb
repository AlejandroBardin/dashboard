require "net/http"

class AnalyzeConversationsJob < ApplicationJob
  queue_as :default

  def perform
    # Trigger payload
    payload = {
      instruction: "Analyze the conversations in your database and send the results back to the Rails webhook"
    }

    # Helper to send to n8n
    n8n_url = Settings.n8n.webhook_url

    uri = URI(n8n_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Bypass SSL for development/demo

    request = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
    request.body = payload.to_json

    response = http.request(request)

    Rails.logger.info "Triggered n8n analysis. Status: #{response.code}"
  end
end
