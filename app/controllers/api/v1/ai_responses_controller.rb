module Api
  module V1
    class AiResponsesController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        # Expecting JSON: { reviews: [ { id: 1, analysis: ... }, ... ] }
        reviews = params[:reviews]

        if reviews.present?
          reviews.each do |review|
            # Try to find by external_id (Chatwoot ID) first, then internal ID
            conversation = Conversation.find_by(external_id: review[:id]) || Conversation.find_by(id: review[:id])
            
            # If still not found, we might want to create it? For now, just skip.
            next unless conversation

            # Upsert/Update the analysis column
            # We strip 'id' from the review hash to store only the metrics in the jsonb column
            analysis_data = review.except(:id, :external_id)

            conversation.update(analysis: analysis_data)
          end

          # Optional: Broadcast update to dashboard if needed, or just let the page refresh handle it
          render json: { status: "success", processed: reviews.size }, status: :ok
        else
          render json: { status: "error", message: "No reviews provided" }, status: :unprocessable_entity
        end
      end
    end
  end
end
