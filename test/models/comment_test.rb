require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test 'valid' do
    comment = FactoryBot.build(:comment_with_post_and_author)
    assert comment.valid?, comment.errors.full_messages
  end
  test 'can save' do
    comment = FactoryBot.build(:comment_with_post_and_author)
    comment.save
    assert_not_nil(comment.id, comment.errors.full_messages)
  end
  test 'author association' do
    user = FactoryBot.create(:user)
    comment = FactoryBot.create(:comment_with_post, author_id: user.id)
    assert_kind_of(User, comment.author)
    assert_equal(comment.author.id, user.id)
  end
  test 'post association' do
    post = FactoryBot.create(:post_with_author)
    comment = FactoryBot.create(:comment_with_author, post_id: post.id)
    assert_kind_of(Post, comment.post)
    assert_equal(comment.post.id, post.id)
  end
end
