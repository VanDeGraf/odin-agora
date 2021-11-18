require "test_helper"

class FriendshipTest < ActiveSupport::TestCase
  test 'valid' do
    friendship = FactoryBot.build(:friendship_with_friends)
    assert friendship.valid?, friendship.errors.full_messages
  end
  test 'can save' do
    friendship = FactoryBot.build(:friendship_with_friends)
    friendship.save
    assert_not_nil(friendship.id, friendship.errors.full_messages)
  end
  test 'friend association' do
    user = FactoryBot.create(:user)
    friendship = FactoryBot.create(:friendship_with_other_friend, friend_id: user.id)
    assert_kind_of(User, friendship.friend)
    assert_equal(friendship.friend.id, user.id)
  end
  test 'other friend association' do
    user = FactoryBot.create(:user)
    friendship = FactoryBot.create(:friendship_with_friend, other_friend_id: user.id)
    assert_kind_of(User, friendship.other_friend)
    assert_equal(friendship.other_friend.id, user.id)
  end
  test 'intersection scope' do
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

    assert_kind_of(ActiveRecord::Relation, Friendship.intersection(user.id, friend_a.id))
    assert_kind_of(Friendship, Friendship.intersection(user.id, friend_a.id).first)

    assert Friendship.intersection(user.id, user.id).empty?
    assert Friendship.intersection(user.id, not_friend.id).empty?

    assert_equal(Friendship.intersection(user.id, friend_a.id).length, 1)
    assert_equal(Friendship.intersection(user.id, friend_a.id).first.towards_user(user), friend_a)
    assert_equal(Friendship.intersection(user.id, friend_b.id).length, 1)
    assert_equal(Friendship.intersection(user.id, friend_b.id).first.towards_user(user), friend_b)
    assert_equal(Friendship.intersection(user.id, friend_c.id).length, 1)
    assert_equal(Friendship.intersection(user.id, friend_c.id).first.towards_user(user), friend_c)
    assert_equal(Friendship.intersection(user.id, friend_d.id).length, 1)
    assert_equal(Friendship.intersection(user.id, friend_d.id).first.towards_user(user), friend_d)
  end
end
