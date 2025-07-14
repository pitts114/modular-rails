# frozen_string_literal: true

class UsersController < ApplicationController
  def new
    # Show the signup form
  end

  def create
    api = UsersApi.new
    result = api.create_user(
      username: user_params[:username],
      password: user_params[:password],
      email: user_params[:email],
      phone_number: user_params[:phone_number]
    )

    if result[:success]
      redirect_to success_users_path, notice: 'Account created successfully!'
    else
      @errors = result[:errors]
      render :new, status: :unprocessable_entity
    end
  end

  def success
    # Show success page after signup
  end

  def login
    # Show the login form
  end

  def authenticate
    # Handle login form submission
    result = UsersApi.new.authenticate_user(
      username: login_params[:username],
      password: login_params[:password]
    )

    if result[:success]
      session[:user_id] = result[:user].id
      redirect_to profile_users_path, notice: 'Successfully logged in!'
    else
      @errors = result[:errors]
      render :login, status: :unprocessable_entity
    end
  end

  def profile
    # Show user profile page
    unless logged_in?
      redirect_to login_users_path, alert: 'Please log in to view your profile'
      return
    end

    api = UsersApi.new
    result = api.get_user_profile(user_id: current_user_id)

    if result[:success]
      @user_data = result[:profile]
    else
      redirect_to login_users_path, alert: 'Unable to load profile. Please log in again.'
    end
  end

  def logout
    # Handle logout
    session[:user_id] = nil
    redirect_to root_path, notice: 'Successfully logged out!'
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :email, :phone_number)
  end

  def login_params
    params.require(:user).permit(:username, :password)
  end

  def logged_in?
    session[:user_id].present?
  end

  def current_user_id
    session[:user_id]
  end
end
