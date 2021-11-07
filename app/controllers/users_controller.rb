class UsersController < ApplicationController
  def profile
    # @type [User]
    @user = User.includes(:posts).find(params[:id])
  end

  def friends
    # @type [User]
    @user = User.find(params[:id])
  end

  def delete_friend
    current_user.delete_friend(params[:id].to_i)
    flash[:notice] = 'User removed from friend list'
    redirect_back fallback_location: '/'
  end

  def cancel_friend_invite
    current_user.cancel_friend_invite(params[:id].to_i)
    flash[:notice] = 'User removed from friend invites list'
    redirect_back fallback_location: '/'
  end

  def invite_friend
    current_user.invite_friend(params[:id].to_i)
    flash[:notice] = 'User invited to yours friend list'
    redirect_back fallback_location: '/'
  end

  def accept_friend_request
    current_user.accept_friend_request(params[:id].to_i)
    flash[:notice] = 'User added to yours friend list'
    redirect_back fallback_location: '/'
  end

  def decline_friend_request
    current_user.decline_friend_request(params[:id].to_i)
    flash[:notice] = 'User friend request declined'
    redirect_back fallback_location: '/'
  end
end
