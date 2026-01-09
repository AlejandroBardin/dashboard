namespace :chatwoot do
  desc "Fetch conversations from Chatwoot and analyze them"
  task :fetch_and_analyze, [:limit] => :environment do |t, args|
    unless ENV['OPENAI_API_KEY']
      puts "Error: OPENAI_API_KEY is required for AI analysis."
      exit 1
    end

    limit = (args[:limit] || 50).to_i
    
    puts "Starting Chatwoot fetch and AI analysis process (Limit: #{limit})..."
    
    fetcher = Chatwoot::Fetcher.new
    saved_conversations = fetcher.fetch_latest(limit: limit)
    
    if saved_conversations.any?
      analyzer = Chatwoot::AiAnalyzer.new
      analyzer.analyze(saved_conversations)
      puts "Done! Fetched and analyzed #{saved_conversations.count} conversations."
    else
      puts "No conversations were fetched."
    end
  end
end
