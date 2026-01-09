class Conversation < ApplicationRecord
  enum :status, { open: 0, sold: 1, dropped: 2, bot_failure: 3 }, default: :open

  validates :external_id, presence: true, uniqueness: true

  scope :this_week, -> { where(created_at: Time.current.beginning_of_week..Time.current.end_of_week) }
  scope :last_week, -> { where(created_at: 1.week.ago.beginning_of_week..1.week.ago.end_of_week) }
  scope :this_month, -> { where(created_at: Time.current.beginning_of_month..Time.current.end_of_month) }


  # Broadcast changes to the dashboard via Turbo Streams
  after_create_commit -> { broadcast_prepend_to "conversations", partial: "dashboards/conversation", locals: { conversation: self }, target: "conversations_list" }
  after_update_commit -> { broadcast_replace_to "conversations", partial: "dashboards/conversation", locals: { conversation: self }, target: "conversation_#{id}" }
end
