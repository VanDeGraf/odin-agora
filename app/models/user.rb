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

  # @return [ActiveRecord::Relation]
  def interlocutors
    join_statement = <<~SQL
      INNER JOIN users ON
            users.id = messages.recipient_id OR users.id = messages.sender_id
    SQL
    where_statement = <<~SQL
      (messages.recipient_id = #{id} OR messages.sender_id = #{id})
        AND users.id <> #{id}
    SQL
    User.reselect('users.*').from('messages').joins(join_statement).unscope(:where).where(where_statement)
        .group('users.id').order('messages.created_at DESC')
  end

  # @param interlocutor_id [Integer] - user id
  def dialog_messages(interlocutor_id)
    join_statement = <<~SQL
      INNER JOIN users ON
            users.id = messages.recipient_id OR users.id = messages.sender_id
    SQL
    where_statement = <<~SQL
        (messages.recipient_id = #{id} AND messages.sender_id = #{interlocutor_id})
      OR (messages.sender_id = #{id} AND messages.recipient_id = #{interlocutor_id})
    SQL
    Message.distinct.joins(join_statement).unscope(:where).where(where_statement).order('messages.created_at')
  end

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

  # @param user [User]
  def friendship_status(user)
    return :friend if friend_ids.include?(user.id)
    return :invited if friend_invite_ids.include?(user.id)
    return :requested if friend_request_ids.include?(user.id)

    nil
  end

  def sex_name
    case sex
    when 1
      'female'
    when 2
      'male'
    else
      ''
    end
  end

  def representative_name
    name = "#{first_name} #{last_name}"
    name = email if name.length <= 1

    name.chomp
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.confirmed_at = DateTime.now.prev_day
      user.password = Devise.friendly_token[0, 20]
      user.birthday = Date.parse(auth.extra.raw_info.birthday) unless auth.extra.raw_info.birthday.nil?
      user.first_name = auth.extra.raw_info.first_name
      user.last_name = auth.extra.raw_info.last_name
      user.sex = case auth.extra.raw_info.sex
                 when 'male'
                   2
                 when 'female'
                   1
                 else
                   0
                 end
      unless auth.extra.raw_info.is_avatar_empty
        user.avatar_url = "https://avatars.yandex.net/get-yapic/#{auth.extra.raw_info.default_avatar_id}/islands-middle"
      end
    end
  end

  private

  # @param friend [User, Integer]
  # @yieldparam friend_id [Integer]
  def sql_with_friend(friend)
    return false unless friend.is_a?(User) || friend.is_a?(Integer)

    friend_id = friend.is_a?(User) ? friend.id : friend
    return if !id.nil? && friend_id == id

    sql = yield friend_id
    # @type [ActiveRecord::Result]
    result = ActiveRecord::Base.connection.exec_query(sql)
    result.rows == 1
  end
end
