class Post < ApplicationRecord
  belongs_to :author, class_name: 'User', inverse_of: :posts
  has_and_belongs_to_many :likes,
                          class_name: 'User',
                          join_table: 'likes',
                          foreign_key: 'post_id'
  has_many :comments

  # @param user [User]
  def liked?(user)
    like_ids.include?(user.id)
  end

  # @param user [User]
  def toggle_like(user)
    return if user.id == author_id

    if liked?(user)
      likes.delete(user)
    else
      likes << user
    end
  end
end
