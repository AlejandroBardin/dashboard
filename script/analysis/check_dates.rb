ids = [588, 510, 523, 559]
sales = Ecommerce::Sale.where(id: ids)
sales.each do |s|
  puts "Sale ##{s.id}: Created: #{s.created_at}, Updated: #{s.updated_at}"
end
