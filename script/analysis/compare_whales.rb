oct_ids = [588, 510, 523, 559]
dec_ids = [679]
all_ids = oct_ids + dec_ids

sales = Ecommerce::Sale.where(id: all_ids).joins(:client).select("sales.id, sales.created_at, sales.total_amount, clients.name as client_name, clients.phone_number")

sales.each do |s|
  puts "Sale ##{s.id} (#{s.created_at.to_date}): $#{s.sale_lines.sum('price*quantity')} - Client: #{s.client_name} (#{s.phone_number})"
end
