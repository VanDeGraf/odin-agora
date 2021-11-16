class UsersController < ApplicationController
  def profile
    # @type [User]
    @user = User.includes(:posts).find(params[:id])
  end

  def friends
    # @type [User]
    @user = User.find(params[:id])
    @friendships = @user.grouped_friendships(invite: @user == current_user)
  end

  def delete_friend
    fs = Friendship.intersection(current_user.id, params[:id].to_i).first
    if fs.nil?
      flash[:notice] = 'Error when try removing User from friend list'
    else
      fs.destroy
      flash[:notice] = 'User removed from friend list'
    end
    redirect_back fallback_location: '/'
  end

  def cancel_friend_invite
    fs = Friendship.intersection(current_user.id, params[:id].to_i).first
    if fs.nil?
      flash[:notice] = 'Error when try removing User from friend invites list'
    else
      fs.destroy
      flash[:notice] = 'User removed from friend invites list'
    end
    redirect_back fallback_location: '/'
  end

  def invite_friend
    fs = Friendship.intersection(current_user.id, params[:id].to_i).first
    if fs.nil?
      Friendship.create(invite: true, friend_id: current_user.id, other_friend_id: params[:id].to_i)
      flash[:notice] = 'User invited to yours friend list'
    else
      flash[:notice] = 'Error when try User invite to yours friend list'
    end
    redirect_back fallback_location: '/'
  end

  def accept_friend_request
    fs = Friendship.intersection(current_user.id, params[:id].to_i).first
    if fs.nil?
      flash[:notice] = 'Error when try User add to yours friend list'
    else
      fs.invite = false
      fs.save
      flash[:notice] = 'User added to yours friend list'
    end
    redirect_back fallback_location: '/'
  end

  def decline_friend_request
    fs = Friendship.intersection(current_user.id, params[:id].to_i).first
    if fs.nil?
      flash[:notice] = 'Error when try removing User from friend request list'
    else
      fs.destroy
      flash[:notice] = 'User friend request declined'
    end
    redirect_back fallback_location: '/'
  end
end
