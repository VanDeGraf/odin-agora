require "test_helper"

class UserTest < ActiveSupport::TestCase
  test 'valid' do
    user = FactoryBot.build(:user)
    assert user.valid?, user.errors.full_messages
  end
  test 'can save' do
    user = FactoryBot.build(:user)
    user.save
    assert_not_nil(user.id, user.errors.full_messages)
  end
  # ---------- Associations ----------------------------
  test 'posts association exists' do
    post_count = 3
    user = FactoryBot.build(:user) do |u|
      post_count.times { u.posts.build(FactoryBot.attributes_for(:post)) }
    end
    assert_kind_of(ActiveRecord::Associations::CollectionProxy, user.posts)
    assert_equal(post_count, user.posts.length)
  end

  test 'posts association creates' do
    user = FactoryBot.build(:user) do |u|
      u.posts.build(FactoryBot.attributes_for(:post))
    end
    user.save
    assert_not_nil(user.posts.first.id, user.errors.full_messages)
  end

  test 'likes association' do
    user_creator = FactoryBot.create(:user)
    user_reader = FactoryBot.create(:user)
    post = user_creator.posts.create(FactoryBot.attributes_for(:post))
    post.likes << user_reader
    assert_equal(1, post.likes.length)
    assert Post.find(post.id).likes.include?(user_reader)
  end

  test 'comments association' do
    user = FactoryBot.create(:user) do |u|
      u.posts.create(FactoryBot.attributes_for(:post))
    end
    comment = user.comments.build(FactoryBot.attributes_for(:comment, post_id: user.posts.first.id))
    assert_kind_of(ActiveRecord::Associations::CollectionProxy, user.comments)
    assert_equal(1, user.comments.length)
    user.save
    assert_not_nil(comment.id, user.errors.full_messages)
  end

  test 'sent and received messages association' do
    user_sender = FactoryBot.create(:user)
    user_recipient = FactoryBot.create(:user)
    message = user_sender.sent_messages.create(FactoryBot.attributes_for(:message, recipient_id: user_recipient.id))
    user_sender.save
    user_recipient = User.find(user_recipient.id)
    assert_not_nil(message.id, user_sender.errors.full_messages)

    assert_kind_of(ActiveRecord::Associations::CollectionProxy, user_sender.sent_messages)
    assert_equal(1, user_sender.sent_messages.length)
    assert_kind_of(ActiveRecord::Associations::CollectionProxy, user_recipient.received_messages)
    assert_equal(1, user_recipient.received_messages.length)
  end

  test 'friendship association' do
    user = FactoryBot.create(:user)
    assert_kind_of(ActiveRecord::Associations::CollectionProxy, user.friendships)
    assert_equal(0, user.friendships.length)
    Friendship.create(invite: false, friend_id: user.id, other_friend_id: FactoryBot.create(:user).id)
    Friendship.create(invite: false, friend_id: FactoryBot.create(:user).id, other_friend_id: user.id)
    Friendship.create(invite: true, friend_id: user.id, other_friend_id: FactoryBot.create(:user).id)
    Friendship.create(invite: true, friend_id: FactoryBot.create(:user).id, other_friend_id: user.id)
    user.reload(lock: true)
    assert_equal(4, user.friendships.length)
  end

  test 'grouped friendships' do
    user = FactoryBot.create(:user)
    Friendship.create(invite: false, friend_id: user.id, other_friend_id: FactoryBot.create(:user).id)
    Friendship.create(invite: false, friend_id: FactoryBot.create(:user).id, other_friend_id: user.id)
    Friendship.create(invite: true, friend_id: user.id, other_friend_id: FactoryBot.create(:user).id)
    Friendship.create(invite: true, friend_id: FactoryBot.create(:user).id, other_friend_id: user.id)
    user.reload(lock: true)

    groups = user.grouped_friendships(invite: false)
    assert groups.key?(:friend)
    assert_equal groups[:friend].length, 2
    assert_kind_of Friendship, groups[:friend].first
    assert groups.key?(:invited)
    assert groups[:invited].empty?
    assert groups.key?(:requested)
    assert groups[:requested].empty?

    groups_with_invite = user.grouped_friendships(invite: true)
    assert groups_with_invite.key?(:friend)
    assert_equal groups_with_invite[:friend].length, 2
    assert_kind_of Friendship, groups_with_invite[:friend].first
    assert groups_with_invite.key?(:invited)
    assert_equal groups_with_invite[:invited].length, 1
    assert_kind_of Friendship, groups_with_invite[:invited].first
    assert groups_with_invite.key?(:requested)
    assert_equal groups_with_invite[:requested].length, 1
    assert_kind_of Friendship, groups_with_invite[:requested].first
  end

  test 'friendship status' do
    user = FactoryBot.create(:user)
    friend_a = FactoryBot.create(:user)
    friend_b = FactoryBot.create(:user)
    friend_c = FactoryBot.create(:user)
    friend_d = FactoryBot.create(:user)
    not_friend = FactoryBot.create(:user)
    Friendship.create(invite: false, friend_id: user.id, other_friend_id: friend_a.id)
    Friendship.create(invite: false, friend_id: friend_b.id, other_friend_id: user.id)
    Friendship.create(invite: true, friend_id: user.id, other_friend_id: friend_c.id)
    Friendship.create(invite: true, friend_id: friend_d.id, other_friend_id: user.id)
    user.reload(lock: true)

    assert_nil user.friendship_status(user)
    assert_nil user.friendship_status(not_friend)
    assert_equal user.friendship_status(friend_a), :friend
    assert_equal user.friendship_status(friend_b), :friend
    assert_equal user.friendship_status(friend_c), :invited
    assert_equal user.friendship_status(friend_d), :requested
  end

  test 'interlocutors' do
    user = FactoryBot.create(:user)
    FactoryBot.create(:message, sender_id: user.id, recipient_id: FactoryBot.create(:user).id)
    FactoryBot.create(:message, sender_id: FactoryBot.create(:user).id, recipient_id: user.id)
    user.reload(lock: true)

    interlocutors = user.interlocutors
    assert_kind_of(Array, interlocutors)
    assert_equal(interlocutors.length, 2)
    assert_kind_of(User, interlocutors.first)
    assert_not_includes(interlocutors, user)
  end

  test 'dialog messages' do
    user = FactoryBot.create(:user)
    interlocutor = FactoryBot.create(:user)
    FactoryBot.create(:message, sender_id: user.id, recipient_id: interlocutor.id)
    FactoryBot.create(:message, sender_id: interlocutor.id, recipient_id: user.id)
    FactoryBot.create(:message, sender_id: user.id, recipient_id: FactoryBot.create(:user).id)
    FactoryBot.create(:message, sender_id: FactoryBot.create(:user).id, recipient_id: user.id)
    user.reload(lock: true)

    messages = user.dialog_messages(interlocutor.id)
    assert_kind_of(Array, messages)
    assert_equal(messages.length, 2)
    assert_kind_of(Message, messages.first)
  end
end
