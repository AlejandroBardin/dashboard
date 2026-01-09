class DashboardsController < ApplicationController
  def index
    @conversations = Conversation.order(created_at: :desc).limit(50)
    # Calculate metrics for the view
    @total_potential = Conversation.sum(:potential_amount)
    @sales_closed = Conversation.sold.sum(:potential_amount)
    @sales_lost = Conversation.dropped.sum(:potential_amount)
    @bot_failures = Conversation.bot_failure.count
  end
end
