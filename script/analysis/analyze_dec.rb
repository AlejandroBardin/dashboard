range = Time.zone.parse("2025-12-01")..Time.zone.parse("2025-12-31").end_of_day
puts "--- SALES ANALYSIS (DEC 2025) ---"

# Total by Status (Undiscarded)
total = Ecommerce::Sale.where(created_at: range, discarded_at: nil, status: ['confirmed', 'delivered', 'ready', 'on_the_way', 'preparing', 'order_placed'])
                       .joins(:sale_lines)
                       .sum("sale_lines.price * sale_lines.quantity")

puts "Total Dec Sales: $#{total.to_f}"
puts "Target (Grafana): ~$1.56M"
puts "Difference: $#{total - 1560000}"

# Check for Whales in Dec
puts "\n--- DEC WHALES ---"
whales = Ecommerce::Sale.where(created_at: range, discarded_at: nil, status: ['confirmed', 'delivered', 'ready', 'on_the_way', 'preparing', 'order_placed'])
                       .joins(:sale_lines)
                       .select("sales.id, sum(sale_lines.price * sale_lines.quantity) as total_value")
                       .group("sales.id")
                       .having("sum(sale_lines.price * sale_lines.quantity) > 55000") # My previous filter threshold
                       .order("total_value DESC")

whales.each do |s|
  puts "Sale ##{s.id}: $#{s.total_value.to_f}"
end
