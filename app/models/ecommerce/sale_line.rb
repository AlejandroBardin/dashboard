module Ecommerce
  class SaleLine < EcommerceRecord
    self.table_name = "sale_lines"

    belongs_to :sale, class_name: "Ecommerce::Sale"
    belongs_to :product, class_name: "Ecommerce::Product"

    def total
      price * quantity
    end
  end
end
