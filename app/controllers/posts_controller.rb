class PostsController < ApplicationController
  def show
    # @type [Post]
    @post = Post.includes(:author, :likes, comments: [:author]).find(params[:id])
  end

  def new; end

  def create; end

  def create_comment; end
end
