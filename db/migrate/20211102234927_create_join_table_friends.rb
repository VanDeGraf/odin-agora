class CreateJoinTableFriends < ActiveRecord::Migration[6.1]
  def change
    create_table :friends, :id => false do |t|
      t.boolean :invite, null: false, index: true
      t.integer :friend_id, null: false, index: true
      t.integer :other_friend_id, null: false, index: true

      t.index [:friend_id, :other_friend_id], unique: true

      t.timestamps
    end
  end
end
