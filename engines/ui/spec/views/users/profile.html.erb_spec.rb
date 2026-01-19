# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/profile.html.erb', type: :view do
  let(:user_data) do
    OpenStruct.new(
      username: 'testuser',
      email: 'test@example.com',
      phone_number: '+1234567890',
      created_at: Time.new(2023, 1, 15, 10, 30, 0)
    )
  end

  before do
    assign(:user_data, user_data)
    render
  end

  it 'displays the profile page title' do
    expect(rendered).to include('Your Profile')
  end

  it 'displays welcome message with username' do
    expect(rendered).to include('Welcome, testuser!')
  end

  it 'displays username' do
    expect(rendered).to include('Username:')
    expect(rendered).to include('testuser')
  end

  it 'displays email' do
    expect(rendered).to include('Email:')
    expect(rendered).to include('test@example.com')
  end

  it 'displays phone number' do
    expect(rendered).to include('Phone Number:')
    expect(rendered).to include('+1234567890')
  end

  it 'displays member since date' do
    expect(rendered).to include('Member Since:')
    expect(rendered).to include('January 15, 2023')
  end

  it 'includes logout button' do
    expect(rendered).to have_selector('form[action="/users/logout"][method="post"]')
    expect(rendered).to have_selector('input[name="_method"][value="delete"]', visible: false)
    expect(rendered).to have_button('Sign Out')
  end

  it 'logout button has confirmation dialog' do
    expect(rendered).to have_selector('form[data-confirm="Are you sure you want to sign out?"]')
  end

  it 'applies profile styling classes' do
    expect(rendered).to have_selector('.profile-container')
    expect(rendered).to have_selector('.profile-header')
    expect(rendered).to have_selector('.profile-info')
    expect(rendered).to have_selector('.info-section')
  end

  context 'with flash messages' do
    context 'when there is a success notice' do
      before do
        flash[:notice] = 'Successfully logged in!'
        assign(:user_data, user_data)
        render
      end

      it 'displays success notice' do
        expect(rendered).to have_selector('.alert.alert-success', text: 'Successfully logged in!')
      end

      it 'applies success styling' do
        expect(rendered).to have_selector('.alert-success')
      end
    end

    context 'when there is an alert message' do
      before do
        flash[:alert] = 'Something went wrong!'
        assign(:user_data, user_data)
        render
      end

      it 'displays alert message' do
        expect(rendered).to have_selector('.alert.alert-danger', text: 'Something went wrong!')
      end

      it 'applies danger styling' do
        expect(rendered).to have_selector('.alert-danger')
      end
    end

    context 'when there are no flash messages' do
      before do
        assign(:user_data, user_data)
        render
      end

      it 'does not display alert containers' do
        expect(rendered).not_to have_selector('.alert')
      end
    end

    context 'when there are both notice and alert messages' do
      before do
        flash[:notice] = 'Profile updated!'
        flash[:alert] = 'Some warning occurred'
        assign(:user_data, user_data)
        render
      end

      it 'displays both messages' do
        expect(rendered).to have_selector('.alert-success', text: 'Profile updated!')
        expect(rendered).to have_selector('.alert-danger', text: 'Some warning occurred')
      end
    end
  end

  context 'when phone number is not provided' do
    let(:user_data_no_phone) do
      OpenStruct.new(
        username: 'testuser',
        email: 'test@example.com',
        phone_number: nil,
        created_at: Time.new(2023, 1, 15, 10, 30, 0)
      )
    end

    before do
      assign(:user_data, user_data_no_phone)
      render
    end

    it 'displays "Not provided" for phone number' do
      expect(rendered).to include('Phone Number:')
      expect(rendered).to include('Not provided')
    end
  end
end
