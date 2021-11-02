class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false, default: ''
      t.string :body, null: false, default: ''
      t.references :author, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
