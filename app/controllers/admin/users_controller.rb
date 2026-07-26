class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def index
    @users = User.order(created_at: :desc)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    # Basic random password for invited users, they can reset it later
    random_password = SecureRandom.hex(8)
    @user.password = random_password
    @user.password_confirmation = random_password

    if @user.save
      redirect_to admin_users_path, notice: "User created with password: #{random_password}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user == current_user
      redirect_to admin_users_path, alert: "You cannot delete yourself."
    else
      @user.destroy
      redirect_to admin_users_path, notice: "User deleted."
    end
  end

  private

  def check_admin
    redirect_to root_path, alert: "Not authorized." unless current_user.admin?
  end

  def user_params
    params.require(:user).permit(:email, :name, :admin)
  end
end
