class SetupController < ApplicationController
  skip_before_action :check_root_user_setup
  before_action :ensure_no_users

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.admin = true if @user.respond_to?(:admin=)

    if @user.save
      sign_in(@user)
      redirect_to root_path, notice: "Welcome to your image host!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def ensure_no_users
    redirect_to new_user_session_path if User.count > 0
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name)
  end
end
