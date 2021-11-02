class Comment < ApplicationRecord
  belongs_to :author, class_name: 'User', inverse_of: :comments
  belongs_to :post
end
