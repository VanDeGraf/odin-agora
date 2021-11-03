class UsersController < ApplicationController
  def profile
    @user = user_from_params
  end

  def friends
    @user = user_from_params
  end

  private

  def user_from_params
    if current_user.id == params[:id]
      current_user
    else
      User.find(params[:id])
    end
  end
end
