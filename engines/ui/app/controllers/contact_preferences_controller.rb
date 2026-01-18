class ContactPreferencesController < ApplicationController
  before_action :require_login

  def show
    users_api = UsersApi.new
    notifications_api = NotificationsApi.new

    profile_result = users_api.get_user_profile(user_id: current_user_id)
    preferences_result = notifications_api.get_contact_preference(user_id: current_user_id)

    if profile_result[:success] && preferences_result[:success]
      @profile = profile_result[:profile]
      @contact_preference = preferences_result[:contact_preference]
    else
      @profile = nil
      @contact_preference = nil
      @errors = (profile_result[:errors] + preferences_result[:errors]).uniq
    end
  end

  def edit
    users_api = UsersApi.new
    notifications_api = NotificationsApi.new

    profile_result = users_api.get_user_profile(user_id: current_user_id)
    preferences_result = notifications_api.get_contact_preference(user_id: current_user_id)

    if profile_result[:success] && preferences_result[:success]
      @profile = profile_result[:profile]
      @contact_preference = preferences_result[:contact_preference]
    else
      redirect_to contact_preferences_path, alert: 'Contact preferences not found'
    end
  end

  def update
    users_api = UsersApi.new
    notifications_api = NotificationsApi.new
    errors = []

    # Update profile information (email, phone) via Users engine
    profile_result = users_api.update_user_profile(
      user_id: current_user_id,
      email: contact_preference_params[:email],
      phone_number: contact_preference_params[:phone_number]
    )
    errors.concat(profile_result[:errors]) unless profile_result[:success]

    # Update notification preferences via Notifications engine
    preferences_result = notifications_api.update_contact_preference(
      user_id: current_user_id,
      email_notifications_enabled: contact_preference_params[:email_notifications_enabled] == '1',
      phone_notifications_enabled: contact_preference_params[:phone_notifications_enabled] == '1'
    )
    errors.concat(preferences_result[:errors]) unless preferences_result[:success]

    if errors.empty?
      redirect_to contact_preferences_path, notice: 'Contact preferences updated successfully!'
    else
      # Re-fetch data for display
      @profile = users_api.get_user_profile(user_id: current_user_id)[:profile]
      @contact_preference = notifications_api.get_contact_preference(user_id: current_user_id)[:contact_preference]
      @errors = errors
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def require_login
    unless logged_in?
      redirect_to login_users_path, alert: 'Please log in to view your contact preferences'
    end
  end

  def logged_in?
    session[:user_id].present?
  end

  def current_user_id
    session[:user_id]
  end

  def contact_preference_params
    params.require(:contact_preference).permit(
      :email, 
      :phone_number, 
      :email_notifications_enabled, 
      :phone_notifications_enabled
    )
  end
end
