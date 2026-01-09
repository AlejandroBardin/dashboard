class EcommerceRecord < ApplicationRecord
  self.abstract_class = true

  establish_connection :ecommerce
  
  # Ensure we don't accidentally write to this DB from this app
  def readonly?
    true
  end
end
