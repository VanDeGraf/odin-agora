class CreateFriendships < ActiveRecord::Migration[6.1]
  def change
    create_table :friendships do |t|
      t.boolean :invite, null: false, index: true
      t.bigint :friend_id, null: false, index: true
      t.bigint :other_friend_id, null: false, index: true

      t.index [:friend_id, :other_friend_id], unique: true

      t.timestamps
    end
  end
end
