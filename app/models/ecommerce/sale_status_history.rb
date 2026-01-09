module Ecommerce
  class SaleStatusHistory < EcommerceRecord
    self.table_name = "sale_status_histories"

    belongs_to :sale, class_name: "Ecommerce::Sale"
  end
end
