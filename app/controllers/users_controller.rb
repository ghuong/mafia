class UsersController < ApplicationController
  def index
  end

  def new
    @user = User.new
  end

  def create
    @room = Room.find_by(code: params[:room_code])
    if @room
      if !@room.is_pregame?
        flash.now[:danger] = "You can no longer join that room."
        render 'static_pages/home' and return
      end

      @user = User.new(name: params[:user][:name], room_id: @room.id)
      if @user.save
        remember @user
        redirect_to room_path(@room.code) and return
      else
        render :new
      end
    else
      flash.now[:danger] = "Room no longer exists."
      render 'static_pages/home'
    end
  end

  def destroy
    user = current_user
    if user
      forget
      user.destroy
      redirect_to root_path
    end
  end
end
