class UserContactPreference < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true, uniqueness: true

  # Default notifications to enabled for new records
  before_validation :set_default_notification_preferences, on: :create

  private

  def set_default_notification_preferences
    self.email_notifications_enabled = true if email_notifications_enabled.nil?
    self.phone_notifications_enabled = true if phone_notifications_enabled.nil?
  end
end
