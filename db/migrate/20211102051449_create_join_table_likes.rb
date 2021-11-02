class CreateJoinTableLikes < ActiveRecord::Migration[6.1]
  def change
    create_join_table :users, :posts, table_name: :likes
  end
end
