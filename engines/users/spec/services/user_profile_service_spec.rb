# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserProfileService do
  let(:user_signup_info_model) { double(:user_signup_info_model) }
  let(:service) { described_class.new(user_signup_info_model: user_signup_info_model) }

  describe '#call' do
    let(:user) do
      double(:user,
        username: 'testuser',
        created_at: Time.new(2023, 1, 15, 10, 30, 0)
      )
    end

    let(:signup_info) do
      double(:signup_info,
        user_id: 'user-123',
        user: user,
        email: 'test@example.com',
        phone_number: '+1234567890'
      )
    end

    context 'when user signup info exists' do
      before do
        allow(user_signup_info_model).to receive(:includes).with(:user).and_return(user_signup_info_model)
        allow(user_signup_info_model).to receive(:find_by).with(user_id: 'user-123').and_return(signup_info)
      end

      it 'returns user profile data as OpenStruct' do
        result = service.call(user_id: 'user-123')

        expect(result).to be_a(OpenStruct)
        expect(result.username).to eq('testuser')
        expect(result.email).to eq('test@example.com')
        expect(result.phone_number).to eq('+1234567890')
        expect(result.created_at).to eq(Time.new(2023, 1, 15, 10, 30, 0))
      end
    end

    context 'when user signup info does not exist' do
      before do
        allow(user_signup_info_model).to receive(:includes).with(:user).and_return(user_signup_info_model)
        allow(user_signup_info_model).to receive(:find_by).with(user_id: 'nonexistent').and_return(nil)
      end

      it 'returns nil' do
        result = service.call(user_id: 'nonexistent')

        expect(result).to be_nil
      end
    end
  end

  describe 'dependency injection' do
    it 'uses default dependencies when none provided' do
      service = described_class.new

      expect(service.instance_variable_get(:@user_signup_info_model)).to eq(UserSignupInfo)
    end

    it 'accepts custom dependencies' do
      custom_model = double(:custom_model)

      service = described_class.new(user_signup_info_model: custom_model)

      expect(service.instance_variable_get(:@user_signup_info_model)).to eq(custom_model)
    end
  end
end
