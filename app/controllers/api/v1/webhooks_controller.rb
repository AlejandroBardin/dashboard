module Api
  module V1
    class WebhooksController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        payload = params.require(:webhook).permit!
        external_id = payload[:id] || payload[:conversation_id]

        conversation = Conversation.find_or_initialize_by(external_id: external_id)

        conversation.raw_data = payload
        conversation.potential_amount = payload[:amount] if payload[:amount].present?

        # Determine status based on payload tags or specific fields
        if payload[:status].present?
          conversation.status = payload[:status].to_s.downcase
        end

        if conversation.save
          render json: { status: "success", id: conversation.id }, status: :ok
        else
          render json: { status: "error", errors: conversation.errors }, status: :unprocessable_entity
        end
      end
    end
  end
end
