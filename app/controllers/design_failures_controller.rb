class DesignFailuresController < ApplicationController
  def index
    # Fetch conversations where design was a factor
    # Analysis flag: sales_outcome -> factors -> design == true
    # Or Loss Reason related to design/files
    # Or Client Metrics has high 'design_need' (>= 8) but sale was lost/dropped

    @failures = Conversation.where(
      "(analysis -> 'sales_outcome' -> 'factors' ->> 'design')::boolean = true OR " \
      "analysis -> 'sales_outcome' ->> 'loss_reason' ILIKE ANY (array['%diseno%', '%diseño%', '%archivo%', '%logo%', '%calidad%', '%pixelado%']) OR " \
      "((analysis -> 'client_metrics' ->> 'design_need')::int >= 8 AND (analysis -> 'sales_outcome' ->> 'result') != 'won')"
    ).order(created_at: :desc).limit(50)
  end
end
