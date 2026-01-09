range = Time.zone.parse("2025-10-01")..Time.zone.parse("2025-10-31").end_of_day
puts "--- SALES ANALYSIS (OCT 2025) ---"

# 1. Total by Status
puts "Breakdown by Status:"
stats = Ecommerce::Sale.where(created_at: range)
                       .joins(:sale_lines)
                       .group(:status)
                       .sum("sale_lines.price * sale_lines.quantity")

stats.each do |k, v|
  puts "#{k}: $#{v.to_f}"
end

sales_statuses = ['confirmed', 'delivered', 'ready', 'on_the_way', 'preparing', 'order_placed']
total_current = stats.select { |k| sales_statuses.include?(k) }.values.sum
puts "\nCurrent 'Ventas' Total: $#{total_current.to_f}"
puts "Target (Grafana): ~$476,000"
puts "Difference: $#{total_current - 476000}"

# 2. Check for Cancelled Outliers
puts "\n--- CANCELLED OUTLIERS ---"
cancelled = Ecommerce::Sale.where(created_at: range, status: 'cancelled')
                           .joins(:sale_lines)
                           .select("sales.id, sum(sale_lines.price * sale_lines.quantity) as total_value")
                           .group("sales.id")
                           .order("total_value DESC")
                           .limit(5)

cancelled.each do |s|
  puts "Sale ##{s.id}: $#{s.total_value}"
end
