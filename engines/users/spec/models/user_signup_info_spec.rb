# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSignupInfo, type: :model do
  describe 'associations' do
    it 'belongs to user' do
      expect(UserSignupInfo.reflect_on_association(:user)).to be_present
      expect(UserSignupInfo.reflect_on_association(:user).macro).to eq(:belongs_to)
    end
  end

  describe 'validations' do
    let(:user) { User.create!(username: 'testuser', password: 'password123') }

    describe 'email validation' do
      it 'validates presence of email' do
        signup_info = UserSignupInfo.new(user: user)
        expect(signup_info).not_to be_valid
        expect(signup_info.errors[:email]).to include("can't be blank")
      end

      it 'validates uniqueness of email' do
        UserSignupInfo.create!(user: user, email: 'test@example.com')

        other_user = User.create!(username: 'otheruser', password: 'password123')
        duplicate_signup_info = UserSignupInfo.new(user: other_user, email: 'test@example.com')

        expect(duplicate_signup_info).not_to be_valid
        expect(duplicate_signup_info.errors[:email]).to include('has already been taken')
      end

      it 'validates email format' do
        signup_info = UserSignupInfo.new(user: user, email: 'invalid-email')
        expect(signup_info).not_to be_valid
        expect(signup_info.errors[:email]).to include('is invalid')
      end

      it 'accepts valid email format' do
        signup_info = UserSignupInfo.new(user: user, email: 'valid@example.com')
        expect(signup_info).to be_valid
      end
    end

    describe 'phone number validation' do
      it 'allows blank phone number' do
        signup_info = UserSignupInfo.new(user: user, email: 'test@example.com', phone_number: '')
        expect(signup_info).to be_valid
      end

      it 'allows nil phone number' do
        signup_info = UserSignupInfo.new(user: user, email: 'test@example.com', phone_number: nil)
        expect(signup_info).to be_valid
      end

      it 'validates phone number format when present' do
        signup_info = UserSignupInfo.new(user: user, email: 'test@example.com', phone_number: 'invalid-phone')
        expect(signup_info).not_to be_valid
        expect(signup_info.errors[:phone_number]).to include('is invalid')
      end

      it 'accepts valid phone number formats' do
        valid_phones = [ '+1234567890', '123-456-7890', '(123) 456-7890', '+1 (123) 456-7890' ]
        valid_phones.each_with_index do |phone, index|
          user = User.create!(username: "user#{index}", password: 'password123')
          signup_info = UserSignupInfo.new(user: user, email: "test#{index}@example.com", phone_number: phone)
          expect(signup_info).to be_valid, "Expected #{phone} to be valid"
        end
      end
    end
  end
end
