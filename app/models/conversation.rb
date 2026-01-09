class Conversation < ApplicationRecord
  enum :status, { open: 0, sold: 1, dropped: 2, bot_failure: 3 }, default: :open

  validates :external_id, presence: true, uniqueness: true

  # Broadcast changes to the dashboard via Turbo Streams
  after_create_commit -> { broadcast_prepend_to "conversations", partial: "dashboards/conversation", locals: { conversation: self }, target: "conversations_list" }
  after_update_commit -> { broadcast_replace_to "conversations", partial: "dashboards/conversation", locals: { conversation: self }, target: "conversation_#{id}" }
end
