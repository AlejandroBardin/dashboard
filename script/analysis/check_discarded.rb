ids = [588, 510, 523, 559]
sales = Ecommerce::Sale.where(id: ids)
sales.each do |s|
  puts "Sale ##{s.id}: Status: #{s.status}, Discarded At: #{s.discarded_at.inspect}, Value: #{s.sale_lines.sum('price * quantity')}"
end

puts "\n--- Total Undiscarded Oct 2025 Sales ---"
range = Time.zone.parse("2025-10-01")..Time.zone.parse("2025-10-31").end_of_day
total = Ecommerce::Sale.where(created_at: range, discarded_at: nil, status: ['confirmed', 'delivered', 'ready', 'on_the_way', 'preparing', 'order_placed'])
                       .joins(:sale_lines)
                       .sum("sale_lines.price * sale_lines.quantity")
puts "Corrected Total: $#{total.to_f}"
