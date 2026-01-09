module Ecommerce
  class Client < EcommerceRecord
    self.table_name = "clients"
    
    has_many :sales, class_name: "Ecommerce::Sale", foreign_key: "client_id"
  end
end
