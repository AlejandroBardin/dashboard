class BotFailuresController < ApplicationController
  def index
    # Only show conversations flagged as bot failures (Rating <= 4 OR Dead Ends)
    @failures = Conversation.where("(analysis -> 'bot_audit' ->> 'rating')::int <= 4 OR (analysis -> 'bot_audit' -> 'friction_points' ->> 'dead_ends')::boolean = true")
                            .order(created_at: :desc)
                            .limit(50)
  end
end
