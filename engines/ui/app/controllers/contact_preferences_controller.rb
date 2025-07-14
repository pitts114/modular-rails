class ContactPreferencesController < ApplicationController
  before_action :require_login

  def show
    api = NotificationsApi.new
    result = api.get_contact_preference(user_id: current_user_id)

    if result[:success]
      @contact_preference = result[:contact_preference]
    else
      @contact_preference = nil
      @errors = result[:errors]
    end
  end

  def edit
    api = NotificationsApi.new
    result = api.get_contact_preference(user_id: current_user_id)

    if result[:success]
      @contact_preference = result[:contact_preference]
    else
      redirect_to contact_preferences_path, alert: 'Contact preferences not found'
    end
  end

  def update
    api = NotificationsApi.new
    result = api.update_contact_preference(
      user_id: current_user_id,
      email: contact_preference_params[:email],
      phone_number: contact_preference_params[:phone_number],
      email_notifications_enabled: contact_preference_params[:email_notifications_enabled] == '1',
      phone_notifications_enabled: contact_preference_params[:phone_notifications_enabled] == '1'
    )

    if result[:success]
      redirect_to contact_preferences_path, notice: 'Contact preferences updated successfully!'
    else
      @contact_preference = result[:contact_preference]
      @errors = result[:errors]
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
