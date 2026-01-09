class DeliveryFailuresController < ApplicationController
  def index
    # Fetch conversations where timing was a factor or loss reason
    # Analysis flag: sales_outcome -> factors -> timing == true
    # Or Loss Reason related to delivery/timing

    @failures = Conversation.where(
      "(analysis -> 'sales_outcome' -> 'factors' ->> 'timing')::boolean = true OR " \
      "analysis -> 'sales_outcome' ->> 'loss_reason' ILIKE ANY (array['%tiempo%', '%demora%', '%envio%', '%entrega%', '%tarde%']) OR " \
      "(analysis -> 'agent_performance' ->> 'response_time_rating')::int <= 5 OR " \
      "analysis -> 'post_sales_analysis' ->> 'delivery_status' = 'delayed' OR " \
      "(analysis -> 'post_sales_analysis' ->> 'customer_anger')::boolean = true"
    ).order(created_at: :desc).limit(50)
  end
end
