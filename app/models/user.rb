class User < ApplicationRecord
  require 'open-uri'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :confirmable, :trackable

  has_many :friendships,
           ->(user) { unscope(:where).where('friend_id = ? OR other_friend_id = ?', user.id, user.id) },
           dependent: :destroy
  has_one_attached :avatar
  has_many :posts, class_name: 'Post', foreign_key: 'author_id', inverse_of: :author, dependent: :destroy
  has_and_belongs_to_many :liked,
                          class_name: 'Post',
                          join_table: 'likes',
                          foreign_key: 'user_id'
  has_many :comments, class_name: 'Comment', foreign_key: 'author_id', inverse_of: :author, dependent: :destroy
  has_many :sent_messages, class_name: 'Message', foreign_key: :sender_id,
           inverse_of: :sender, dependent: :destroy
  has_many :received_messages, class_name: 'Message', foreign_key: :recipient_id,
           inverse_of: :recipient, dependent: :destroy

  def grouped_friendships(invite: false)
    groups = {
      friend: [],
      invited: [],
      requested: []
    }
    if invite
      friendships.find_each do |friendship|
        groups[friendship.friendship_status(self)] << friendship
      end
    else
      friendships.where(invite: false).find_each do |friendship|
        groups[:friend] << friendship
      end
    end
    groups
  end

  def friendship_status(user)
    status = nil
    friendships.find_each do |friendship|
      unless (status = friendship.friendship_status(user)).nil?
        return case status
               when :invited
                 :requested
               when :requested
                 :invited
               else
                 status
               end
      end
    end
    status
  end

  def friend_request_count
    Friendship.where(other_friend_id: id, invite: true).count
  end

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
        .group('users.id').sort_by(&:created_at).reverse
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
    Message.distinct.joins(join_statement).unscope(:where).where(where_statement).sort_by(&:created_at)
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
        avatar_url = "https://avatars.yandex.net/get-yapic/#{auth.extra.raw_info.default_avatar_id}/islands-middle"
        user.attach_avatar_from_url(avatar_url)
      end
    end
  end

  def attach_avatar_from_url(url)
    file = URI.open(url)
    avatar.attach(io: file,
                  filename: "temp.#{file.content_type_parse.first.split('/').last}",
                  content_type: file.content_type_parse.first)
  end
end
