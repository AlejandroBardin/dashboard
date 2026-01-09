class AnalyzeConversationsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting AI Sync Job (Chatwoot Fetch + OpenAI Analysis)..."

    # Quick check for required env vars
    missing_vars = []
    missing_vars << 'CHATWOOT_API_TOKEN' unless ENV['CHATWOOT_API_TOKEN']
    missing_vars << 'CHATWOOT_ACCOUNT_ID' unless ENV['CHATWOOT_ACCOUNT_ID']
    missing_vars << 'OPENAI_API_KEY' unless ENV['OPENAI_API_KEY']

    if missing_vars.any?
      Rails.logger.error "AI Sync Job Aborted. Missing environment variables: #{missing_vars.join(', ')}"
      return
    end

    begin
      # 1. Fetch last 100 conversations
      Rails.logger.info "Fetching last 100 conversations from Chatwoot..."
      fetcher = Chatwoot::Fetcher.new
      conversations = fetcher.fetch_latest(limit: 100)

      if conversations.any?
        # 2. Analyze using AI
        Rails.logger.info "Analyzing #{conversations.count} conversations with OpenAI..."
        analyzer = Chatwoot::AiAnalyzer.new
        analyzer.analyze(conversations)

        # 3. Global Auditor Diagnosis
        Rails.logger.info "Running Global Auditor Diagnosis..."
        Chatwoot::GlobalAuditor.run
        
        Rails.logger.info "AI Sync Job Completed successfully. #{conversations.count} conversations processed."
      else
        Rails.logger.info "AI Sync Job: No conversations were fetched from Chatwoot."
      end

    rescue StandardError => e
      Rails.logger.error "AI Sync Job Failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
