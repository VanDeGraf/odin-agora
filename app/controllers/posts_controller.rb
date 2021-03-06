class PostsController < ApplicationController
  def show
    # @type [Post]
    @post = Post.includes(:author, :likes, comments: [:author]).find(params[:id])
    @comment = Comment.new
  end

  def new
    @post = Post.new
  end

  def create
    permitted = params.required(:post).permit(:title, :body, :picture)
    @post = current_user.posts.create(title: permitted[:title], body: permitted[:body], picture: permitted[:picture])
    flash[:notice] = 'Successfully post create'
    redirect_to @post
  end

  def create_comment
    permitted = params.required(:comment).permit(:body)
    @comment = current_user.comments.create(body: permitted[:body], post_id: params[:id].to_i)
    flash[:notice] = 'Successfully add comment'
    redirect_to @comment.post
  end

  def toggle_like
    @post = Post.find(params[:id])
    @post.toggle_like(current_user)
    @post.save
    redirect_back fallback_location: post_path(@post)
  end
end
