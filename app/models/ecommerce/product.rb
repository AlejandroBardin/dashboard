module Ecommerce
  class Product < EcommerceRecord
    self.table_name = "products"
    
    has_many :sale_lines, class_name: "Ecommerce::SaleLine", foreign_key: "product_id"
  end
end
