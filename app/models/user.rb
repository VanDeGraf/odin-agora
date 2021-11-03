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
  has_many :friends,
           lambda { |user|
             join_statement = <<~SQL
               INNER JOIN friends f ON
                      (f.friend_id = id OR f.other_friend_id = id)
                  AND (f.friend_id = #{user.id} OR f.other_friend_id = #{user.id})
                  AND f.invite = false
             SQL
             User.joins(join_statement).unscope(:where).where.not(id: user.id)
           }, class_name: 'User'
  has_many :sent_messages, class_name: 'Message', foreign_key: :sender_id, inverse_of: :sender
  has_many :received_messages, class_name: 'Message', foreign_key: :recipient_id, inverse_of: :recipient
  # called other users to your friend list
  has_many :friend_invites,
           lambda { |user|
             join_statement = <<~SQL
               INNER JOIN friends f ON
                      f.friend_id = #{user.id}
                  AND f.other_friend_id = id
                  AND f.invite = true
             SQL
             User.joins(join_statement).unscope(:where)
           }, class_name: 'User'
  # other users called you to their friend lists
  has_many :friend_requests,
           lambda { |user|
             join_statement = <<~SQL
               INNER JOIN friends f ON
                      f.other_friend_id = #{user.id}
                  AND f.friend_id = id
                  AND f.invite = true
             SQL
             User.joins(join_statement).unscope(:where)
           }, class_name: 'User'

  # @param friend [User, Integer]
  def delete_friend(friend)
    sql_with_friend(friend) do |friend_id|
      <<~SQL
        DELETE
        FROM friends
        WHERE (friend_id = #{id} AND other_friend_id = #{friend_id})
           OR (friend_id = #{friend_id} AND other_friend_id = #{id})
      SQL
    end
  end

  # @param friend [User]
  def accept_friend_request(friend)
    sql_with_friend(friend) do |friend_id|
      <<~SQL
        UPDATE friends
        SET invite = false
        WHERE friend_id = #{friend_id} AND other_friend_id = #{id}
      SQL
    end
  end

  alias decline_friend_request delete_friend

  # @param friend [User]
  def invite_friend(friend)
    cur_date = DateTime.now.new_offset(0).to_formatted_s(:db)
    sql_with_friend(friend) do |friend_id|
      <<~SQL
        INSERT INTO friends
        VALUES (true, #{id}, #{friend_id}, "#{cur_date}", "#{cur_date}")
      SQL
    end
  end

  alias cancel_friend_invite delete_friend

  private

  # @param friend [User, Integer]
  # @yieldparam friend_id [Integer]
  def sql_with_friend(friend)
    return false unless friend.is_a?(User) || friend.is_a?(Integer)

    friend_id = friend.is_a?(User) ? friend.id : friend
    sql = yield friend_id
    # @type [ActiveRecord::Result]
    result = ActiveRecord::Base.connection.exec_query(sql)
    result.rows == 1
  end
end
