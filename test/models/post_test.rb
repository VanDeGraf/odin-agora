require "test_helper"

class PostTest < ActiveSupport::TestCase
  test 'valid' do
    post = FactoryBot.build(:post_with_author)
    assert post.valid?, post.errors.full_messages
  end
  test 'can save' do
    post = FactoryBot.build(:post_with_author)
    post.save
    assert_not_nil(post.id, post.errors.full_messages)
  end
  test 'author association' do
    user = FactoryBot.create(:user)
    post = FactoryBot.create(:post, author_id: user.id)
    assert_kind_of(User, post.author)
    assert_equal(post.author.id, user.id)
  end
  test 'likes association' do
    user = FactoryBot.create(:user)
    post = FactoryBot.create(:post_with_author)

    assert_kind_of(ActiveRecord::Associations::CollectionProxy, post.likes)

    post.likes << user
    assert_equal(1, post.likes.length)
    assert_kind_of(User, post.likes.first)
    assert post.likes.include?(user)
  end
  test 'comments association' do
    post = FactoryBot.create(:post_with_author)
    comment = FactoryBot.create(:comment_with_author, post_id: post.id)
    post.reload(lock: true)

    assert_kind_of(ActiveRecord::Associations::CollectionProxy, post.comments)
    assert_equal(post.comments.length, 1)
    assert_kind_of(Comment, post.comments.first)
    assert_equal(post.comments.first.id, comment.id)
  end
end
