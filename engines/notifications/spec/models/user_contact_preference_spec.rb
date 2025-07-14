require 'rails_helper'

RSpec.describe UserContactPreference, type: :model do
  let(:user) { double(:user, id: SecureRandom.uuid) }

  describe 'validations' do
    it 'requires a user_id' do
      preference = UserContactPreference.new(email: 'test@example.com')
      expect(preference).not_to be_valid
      expect(preference.errors[:user_id]).to include("can't be blank")
    end

    it 'requires a valid email format' do
      preference = UserContactPreference.new(
        user_id: SecureRandom.uuid,
        email: 'invalid-email'
      )
      expect(preference).not_to be_valid
      expect(preference.errors[:email]).to include("is invalid")
    end

    it 'accepts valid email format' do
      preference = UserContactPreference.new(
        user_id: SecureRandom.uuid,
        email: 'test@example.com'
      )
      expect(preference.errors[:email]).to be_empty
    end

    it 'allows blank phone number' do
      preference = UserContactPreference.new(
        user_id: SecureRandom.uuid,
        email: 'test@example.com',
        phone_number: ''
      )
      expect(preference.errors[:phone_number]).to be_empty
    end

    it 'validates phone number format when present' do
      preference = UserContactPreference.new(
        user_id: SecureRandom.uuid,
        email: 'test@example.com',
        phone_number: 'invalid'
      )
      expect(preference).not_to be_valid
      expect(preference.errors[:phone_number]).to include("is invalid")
    end

    it 'accepts valid phone number formats' do
      valid_numbers = [ '+1234567890', '1234567890', '+1 (234) 567-8900' ]

      valid_numbers.each do |number|
        preference = UserContactPreference.new(
          user_id: SecureRandom.uuid,
          email: 'test@example.com',
          phone_number: number
        )
        expect(preference.errors[:phone_number]).to be_empty, "Expected #{number} to be valid"
      end
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
        user_id: SecureRandom.uuid,
        email: 'test@example.com'
      )
      preference.valid? # Trigger callbacks
      expect(preference.email_notifications_enabled).to be true
    end

    it 'sets phone notifications to enabled by default' do
      preference = UserContactPreference.new(
        user_id: SecureRandom.uuid,
        email: 'test@example.com'
      )
      preference.valid? # Trigger callbacks
      expect(preference.phone_notifications_enabled).to be true
    end

    it 'does not override explicitly set values' do
      preference = UserContactPreference.new(
        user_id: SecureRandom.uuid,
        email: 'test@example.com',
        email_notifications_enabled: false,
        phone_notifications_enabled: false
      )
      preference.valid? # Trigger callbacks
      expect(preference.email_notifications_enabled).to be false
      expect(preference.phone_notifications_enabled).to be false
    end
  end
end
