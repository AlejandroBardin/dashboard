module Ecommerce
  class Sale < EcommerceRecord
    self.table_name = "sales"

    has_many :sale_lines, class_name: "Ecommerce::SaleLine", foreign_key: "sale_id"
    belongs_to :client, class_name: "Ecommerce::Client", optional: true
    has_many :sale_status_histories, class_name: "Ecommerce::SaleStatusHistory", foreign_key: "sale_id"

    scope :active, -> { where(discarded_at: nil) }
    scope :not_cancelled, -> { where.not(status: 'cancelled') }
    
    # Scopes for dashboard
    scope :this_month, -> { where(created_at: Time.current.beginning_of_month..Time.current.end_of_month) }
    scope :last_month, -> { where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month) }
  end
end
