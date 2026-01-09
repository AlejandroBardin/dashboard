range = Time.zone.parse("2025-10-01")..Time.zone.parse("2025-10-31").end_of_day

# 1. Inspect Delivered Sales
puts "--- DELIVERED SALES (OCT 2025) ---"
delivered = Ecommerce::Sale.where(created_at: range, status: 'delivered')
                           .joins(:sale_lines)
                           .select("sales.id, sum(sale_lines.price * sale_lines.quantity) as total_value")
                           .group("sales.id")
                           .order("total_value DESC")

delivered.each do |s|
  puts "Sale ##{s.id}: $#{s.total_value.to_f}"
end

# 2. Inspect Pending (just in case)
puts "\n--- PENDING SALES (OCT 2025) Top 5 ---"
pending = Ecommerce::Sale.where(created_at: range, status: 'pending')
                       .joins(:sale_lines)
                       .select("sales.id, sum(sale_lines.price * sale_lines.quantity) as total_value")
                       .group("sales.id")
                       .order("total_value DESC")
                       .limit(5)
pending.each do |s|
  puts "Sale ##{s.id}: $#{s.total_value.to_f}"
end
