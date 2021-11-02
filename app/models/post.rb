class Post < ApplicationRecord
  belongs_to :author, class_name: 'User', inverse_of: :posts
  has_and_belongs_to_many :likes,
                          class_name: 'User',
                          join_table: 'likes',
                          foreign_key: 'post_id'
end
