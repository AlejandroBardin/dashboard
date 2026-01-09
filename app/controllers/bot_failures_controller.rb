class BotFailuresController < ApplicationController
  def index
    # Only show conversations flagged as bot failures
    # We eager load messages if we want to show chat history, 
    # but for now we rely on the conversation data and analysis.
    @failures = Conversation.bot_failure.order(created_at: :desc).limit(50)
  end
end
