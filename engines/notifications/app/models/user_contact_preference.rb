class UserContactPreference < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, allow_blank: true, format: { with: /\A[\+]?[1-9][\d\s\-\(\)]*\z/ }

  # Default notifications to enabled for new records
  before_validation :set_default_notification_preferences, on: :create

  private

  def set_default_notification_preferences
    self.email_notifications_enabled = true if email_notifications_enabled.nil?
    self.phone_notifications_enabled = true if phone_notifications_enabled.nil?
  end
end
