class AddAnalysisToConversations < ActiveRecord::Migration[8.1]
  def change
    add_column :conversations, :analysis, :jsonb
  end
end
