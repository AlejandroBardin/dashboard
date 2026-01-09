class DashboardsController < ApplicationController
  def index
    @range = params[:range] || "this_week"

    @filter_scope = case @range
    when "today" then Conversation.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day)
    when "this_week" then Conversation.this_week
    when "last_week" then Conversation.last_week
    when "this_month" then Conversation.this_month
    else Conversation.all
    end

    @conversations = @filter_scope.order(created_at: :desc).limit(50)

    # Calculate metrics for the view based on the filtered scope
    @total_potential = @filter_scope.sum(:potential_amount)
    @sales_closed = @filter_scope.sold.sum(:potential_amount)
    @sales_lost = @filter_scope.dropped.sum(:potential_amount)
    @bot_failures = @filter_scope.bot_failure.count
  end

  def analyze
    AnalyzeConversationsJob.perform_later
    redirect_to root_path, notice: "Análisis IA solicitado. Los gráficos se actualizarán pronto."
  end
end
