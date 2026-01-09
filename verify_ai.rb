
# Verification Script for AI Analysis
puts "Checking recent conversations analysis..."
recent = Conversation.order(updated_at: :desc).limit(3)

recent.each do |c|
  puts "ID: #{c.id}, External ID: #{c.external_id}"
  # Just pretty print the analysis
  puts JSON.pretty_generate(c.analysis)
  puts "-----------------------------------"
end
