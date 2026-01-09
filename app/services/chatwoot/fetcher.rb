require 'net/http'
require 'json'

module Chatwoot
  class Fetcher
    BASE_URL = "https://chatwoot.grafica.xetro.com.ar"

    def initialize
      @api_token = ENV['CHATWOOT_API_TOKEN']
      @account_id = ENV['CHATWOOT_ACCOUNT_ID']
    end

    def fetch_latest(limit: 50)
      puts "Fetching last #{limit} conversations..."
      accumulated_data = []
      page = 1

      while accumulated_data.size < limit
        fetched = fetch_page(page, limit)
        break if fetched.empty?

        fetched.each do |conv_data|
          break if accumulated_data.size >= limit
          
          full_conv = process_conversation(conv_data)
          accumulated_data << full_conv if full_conv
        end
        
        page += 1
      end
      
      puts "Processed #{accumulated_data.size} conversations."
      accumulated_data
    end

    private

    def fetch_page(page, limit)
      # We fetch 25 per page from Chatwoot by default usually if not specified, 
      # but let's stick to simple pagination.
      url = URI("#{BASE_URL}/api/v1/accounts/#{@account_id}/conversations?limit=25&page=#{page}")
      
      response = make_request(url)
      return [] unless response
      
      data = JSON.parse(response.body)
      data.dig('data', 'payload') || []
    end

    def process_conversation(conv_data)
      chat_id = conv_data['id']
      puts "  Processing conversation ##{chat_id}..."
      
      messages_payload = fetch_messages(chat_id)
      
      # Upsert into local database
      conversation = Conversation.find_or_initialize_by(external_id: chat_id.to_s)
      
      # We store the raw data as requested
      raw_payload = {
        "conversation_id" => chat_id,
        "meta" => conv_data,
        "messages" => messages_payload
      }
      
      conversation.raw_data = raw_payload
      # Map basic status if possible, or just default to open
      # conversation.status = map_status(conv_data['status']) 
      
      if conversation.save
        conversation
      else
        puts "    Failed to save conversation #{chat_id}: #{conversation.errors.full_messages}"
        nil
      end
    end

    def fetch_messages(conversation_id)
      url = URI("#{BASE_URL}/api/v1/accounts/#{@account_id}/conversations/#{conversation_id}/messages")
      response = make_request(url)
      return [] unless response

      data = JSON.parse(response.body)
      data.dig('payload') || []
    end

    def make_request(url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == "https")
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE 
      
      request = Net::HTTP::Get.new(url)
      request["api_access_token"] = @api_token
      request["Content-Type"] = "application/json"

      begin
        response = http.request(request)
        if response.is_a?(Net::HTTPSuccess)
          response
        else
          puts "    Error fetching #{url}: #{response.code} #{response.message}"
          nil
        end
      rescue StandardError => e
        puts "    Exception fetching #{url}: #{e.message}"
        nil
      end
    end
  end
end
