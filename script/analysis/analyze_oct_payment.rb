range = Time.zone.parse("2025-10-01")..Time.zone.parse("2025-10-31").end_of_day
puts "--- DELIVERED SALES BREAKDOWN (OCT 2025) ---"

puts "By Payment Status:"
stats = Ecommerce::Sale.where(created_at: range, status: 'delivered')
                       .joins(:sale_lines)
                       .group(:payment_status)
                       .sum("sale_lines.price * sale_lines.quantity")

stats.each { |k, v| puts "#{k}: $#{v.to_f}" }

puts "\nBy Source:"
stats_source = Ecommerce::Sale.where(created_at: range, status: 'delivered')
                       .joins(:sale_lines)
                       .group(:source)
                       .sum("sale_lines.price * sale_lines.quantity")
stats_source.each { |k, v| puts "#{k}: $#{v.to_f}" }
