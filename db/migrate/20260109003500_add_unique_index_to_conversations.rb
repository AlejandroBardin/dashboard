class AddUniqueIndexToConversations < ActiveRecord::Migration[8.1]
  def change
    remove_index :conversations, :external_id
    add_index :conversations, :external_id, unique: true
  end
end
