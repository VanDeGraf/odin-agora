class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :confirmable, :trackable
  has_many :posts, class_name: 'Post', foreign_key: 'author_id', inverse_of: :author
  has_and_belongs_to_many :liked,
                          class_name: 'Post',
                          join_table: 'likes',
                          foreign_key: 'user_id'
  has_many :comments, class_name: 'Comment', foreign_key: 'author_id', inverse_of: :author
end
