class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :first_name, null: false, default: ''
      t.string :last_name, null: false, default: ''
      t.integer :sex
      t.date :birthday
      t.string :avatar_url

      t.timestamps
    end
  end
end
