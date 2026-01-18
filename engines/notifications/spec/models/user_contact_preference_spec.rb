require 'rails_helper'

RSpec.describe UserContactPreference, type: :model do
  let(:user) { double(:user, id: SecureRandom.uuid) }

  describe 'validations' do
    it 'requires a user_id' do
      preference = UserContactPreference.new
      expect(preference).not_to be_valid
      expect(preference.errors[:user_id]).to include("can't be blank")
    end

    it 'enforces unique user_id' do
      existing_user_id = SecureRandom.uuid

      # This would need to be tested with actual database persistence
      # For now, we'll test the validation rule exists
      preference = UserContactPreference.new(user_id: existing_user_id)
      expect(preference.class.validators_on(:user_id).map(&:class)).to include(ActiveRecord::Validations::UniquenessValidator)
    end
  end

  describe 'default notification preferences' do
    it 'sets email notifications to enabled by default' do
      preference = UserContactPreference.new(
        user_id: SecureRandom.uuid
      )
      preference.valid? # Trigger callbacks
      expect(preference.email_notifications_enabled).to be true
    end

    it 'sets phone notifications to enabled by default' do
      preference = UserContactPreference.new(
        user_id: SecureRandom.uuid
      )
      preference.valid? # Trigger callbacks
      expect(preference.phone_notifications_enabled).to be true
    end

    it 'does not override explicitly set values' do
      preference = UserContactPreference.new(
        user_id: SecureRandom.uuid,
        email_notifications_enabled: false,
        phone_notifications_enabled: false
      )
      preference.valid? # Trigger callbacks
      expect(preference.email_notifications_enabled).to be false
      expect(preference.phone_notifications_enabled).to be false
    end
  end
end
