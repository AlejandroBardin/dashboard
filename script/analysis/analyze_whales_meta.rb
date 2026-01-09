ids = [588, 510, 523, 559]
whales = Ecommerce::Sale.where(id: ids)
puts "--- WHALE SALES METADATA ---"
whales.each do |s|
  puts "Sale ##{s.id}: Branch: #{s.branch_id}, User/Op: #{s.operador_id}, Source: #{s.source}"
end

puts "\n--- NORMAL SALES (Sample) ---"
normal = Ecommerce::Sale.where.not(id: ids).where(created_at: Time.zone.parse("2025-10-01")..Time.zone.parse("2025-10-30")).limit(5)
normal.each do |s|
  puts "Sale ##{s.id}: Branch: #{s.branch_id}, User/Op: #{s.operador_id}, Source: #{s.source}"
end
