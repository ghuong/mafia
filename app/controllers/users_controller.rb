class UsersController < ApplicationController
  before_action :room_is_pregame, except: [:destroy]
  before_action :not_in_room, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(name: params[:user][:name], room_id: @room.id)
    if @user.save
      remember @user
      redirect_to room_path(@room.code) and return
    else
      render :new
    end
  end

  def destroy
    user = current_user
    forget
    if user
      user.destroy
      redirect_to root_path
    end
  end

  private

    def room_is_pregame
      @room = Room.find_by(code: params[:room_code])
      if !@room || !@room.is_pregame?
        flash[:danger] = "That game has already started, or does not exist."
        redirect_to root_path
      end
    end

    def not_in_room
      if is_in_a_room?
        redirect_to room_path(current_user.room.code)
      end
    end
end
