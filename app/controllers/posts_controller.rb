class PostsController < ApplicationController
  def show
    # @type [Post]
    @post = Post.includes(:author, :likes, comments: [:author]).find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    permitted = params.required(:post).permit(:title, :body)
    @post = current_user.posts.create(title: permitted[:title], body: permitted[:body])
    flash[:notice] = 'Successfully post create'
    redirect_to @post
  end

  def create_comment; end
end
