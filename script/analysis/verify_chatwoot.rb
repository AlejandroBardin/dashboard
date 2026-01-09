
# Verification Script
puts "Checking recent conversations..."
recent = Conversation.order(updated_at: :desc).limit(5)

recent.each do |c|
  puts "ID: #{c.id}, External ID: #{c.external_id}"
  puts "  Raw Data Keys: #{c.raw_data&.keys}"
  puts "  Messages Count: #{c.raw_data['messages']&.count}"
  puts "  Analysis: #{c.analysis}"
  puts "-----------------------------------"
end
