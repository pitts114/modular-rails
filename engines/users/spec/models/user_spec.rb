# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it 'has one user signup info' do
      expect(User.reflect_on_association(:user_signup_info)).to be_present
      expect(User.reflect_on_association(:user_signup_info).macro).to eq(:has_one)
    end
  end

  describe 'validations' do
    it 'validates presence of username' do
      user = User.new(password: 'password123')
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("can't be blank")
    end

    it 'validates uniqueness of username' do
      User.create!(username: 'testuser', password: 'password123')
      duplicate_user = User.new(username: 'testuser', password: 'password456')
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:username]).to include('has already been taken')
    end

    it 'validates presence of password' do
      user = User.new(username: 'testuser')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end
  end

  describe 'password authentication' do
    let(:user) { User.create!(username: 'testuser', password: 'password123') }

    it 'authenticates with correct password' do
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'does not authenticate with incorrect password' do
      expect(user.authenticate('wrongpassword')).to be_falsey
    end

    it 'stores password as digest' do
      expect(user.password_digest).to be_present
      expect(user.password_digest).not_to eq('password123')
    end
  end

  describe 'delegation' do
    let(:user) { User.create!(username: 'testuser', password: 'password123') }

    context 'when user has signup info' do
      before do
        user.create_user_signup_info!(email: 'test@example.com', phone_number: '+1234567890')
      end

      it 'delegates email to user signup info' do
        expect(user.email).to eq('test@example.com')
      end

      it 'delegates phone_number to user signup info' do
        expect(user.phone_number).to eq('+1234567890')
      end
    end

    context 'when user has no signup info' do
      it 'returns nil for email' do
        expect(user.email).to be_nil
      end

      it 'returns nil for phone_number' do
        expect(user.phone_number).to be_nil
      end
    end
  end
end
