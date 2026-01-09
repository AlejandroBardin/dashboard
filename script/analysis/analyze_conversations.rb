puts "Current Time: #{Time.current}"
puts "Range: #{3.months.ago.beginning_of_month} to #{Time.current.end_of_day}"

all_count = Conversation.count
in_range_count = Conversation.where(created_at: 3.months.ago.beginning_of_month..Time.current.end_of_day).count

puts "Total Conversations: #{all_count}"
puts "In Range Conversations: #{in_range_count}"

if all_count > 0
  puts "\nOldest Conv: #{Conversation.minimum(:created_at)}"
  puts "Newest Conv: #{Conversation.maximum(:created_at)}"
  
  puts "\nSample with Analysis:"
  analyzed = Conversation.where.not(analysis: nil).limit(5)
  analyzed.each do |c|
    puts "ID: #{c.id}, Created: #{c.created_at}, Analysis Keys: #{c.analysis.keys}"
  end
end
