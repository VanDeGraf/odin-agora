class Friendship < ApplicationRecord
  belongs_to :friend, class_name: 'User'
  belongs_to :other_friend, class_name: 'User'

  scope :intersection, lambda { |user1_id, user2_id|
    where(<<~SQL
        (friend_id = #{user1_id} AND other_friend_id = #{user2_id}) OR
      (friend_id = #{user2_id} AND other_friend_id = #{user1_id})
    SQL
    )
  }

  # @param user [User]
  # @return [Symbol]
  def friendship_status(user)
    if friend == user
      invite ? :invited : :friend
    elsif other_friend == user
      invite ? :requested : :friend
    else
      nil
    end
  end

  # @param user [User, NilClass]
  def towards_user(user, friendship = :any)
    return nil if friendship != :any && friendship != friendship_status(user)

    friend == user ? other_friend : friend
  end

  # @param user [User]
  # @return [Symbol] new friendship status for user
  def toggle_invite(user)
    self.invite = !invite
    friendship_status(user)
  end
end
