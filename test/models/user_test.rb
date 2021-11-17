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
    # @type [Post]
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
end
