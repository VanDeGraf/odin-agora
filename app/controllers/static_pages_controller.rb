class StaticPagesController < ApplicationController
  def people
    join_statement = <<~SQL
         LEFT JOIN friends f ON
      f.friend_id = users.id OR f.other_friend_id = users.id
    SQL
    where_statement = <<~SQL
      users.id NOT IN (
          SELECT u.id
          FROM users as u
                   INNER JOIN friends f2 ON
                  (f2.friend_id = u.id OR f2.other_friend_id = u.id)
                  AND (f2.friend_id = #{current_user.id} OR f2.other_friend_id = #{current_user.id})
      )
    SQL
    @people = User.joins(join_statement).where(where_statement).group('id').order('COUNT(id)')
  end

  def feed
    posts = Post.distinct.includes(:author).joins(friends_children_join('posts')).order('created_at DESC')
    comments = Comment.distinct.includes(:author).joins(friends_children_join('comments')).order('created_at DESC')
    # @type [Array<Post,Comment>]
    @feed = (posts + comments).sort_by!(&:created_at).reverse
  end

  def about; end

  private

  def friends_children_join(table)
    <<~SQL
      INNER JOIN users f ON
            #{table}.author_id = f.id AND f.id <> #{current_user.id}
      INNER JOIN friends f_join ON
            (f_join.friend_id = f.id OR f_join.other_friend_id = f.id)
        AND (f_join.friend_id = #{current_user.id} OR f_join.other_friend_id = #{current_user.id})
    SQL
  end
end
