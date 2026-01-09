class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.string :external_id
      t.jsonb :raw_data
      t.integer :status
      t.decimal :potential_amount

      t.timestamps
    end
    add_index :conversations, :external_id
  end
end
