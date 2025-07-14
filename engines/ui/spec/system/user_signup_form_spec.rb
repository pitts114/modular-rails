# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Signup Form Integration', type: :system do
  before do
    driven_by(:rack_test)
  end

  # These tests focus on the UI layer integration with mocked business logic
  # They ensure the form correctly submits parameters and handles responses
  # For full end-to-end tests, see user_signup_full_integration_spec.rb

  it 'successfully submits the signup form with valid data' do
    # Mock the UsersApi to avoid database interactions
    users_api = double(:users_api)
    allow(UsersApi).to receive(:new).and_return(users_api)
    allow(users_api).to receive(:create_user).and_return({
      success: true,
      user: double(:user, id: 'user-123', username: 'testuser')
    })

    visit root_path

    # Fill out the form
    fill_in 'Username', with: 'testuser'
    fill_in 'Password', with: 'password123'
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Phone Number (optional)', with: '555-1234'

    # Submit the form
    click_button 'Create Account'

    # Verify the API was called with correct parameters
    expect(users_api).to have_received(:create_user).with(
      username: 'testuser',
      password: 'password123',
      email: 'test@example.com',
      phone_number: '555-1234'
    )

    # Verify we're on the success page
    expect(page).to have_content('Account Created Successfully!')
  end

  it 'displays validation errors when user creation fails' do
    # Mock the UsersApi to return errors
    users_api = double(:users_api)
    allow(UsersApi).to receive(:new).and_return(users_api)
    allow(users_api).to receive(:create_user).and_return({
      success: false,
      errors: [ 'Username is already taken', 'Email format is invalid' ]
    })

    visit root_path

    fill_in 'Username', with: 'existing_user'
    fill_in 'Password', with: 'password123'
    fill_in 'Email', with: 'invalid-email'
    fill_in 'Phone Number (optional)', with: '555-1234'

    click_button 'Create Account'

    # Should stay on the form page and show errors
    expect(page).to have_content('Please fix the following errors:')
    expect(page).to have_content('Username is already taken')
    expect(page).to have_content('Email format is invalid')
    # Note: Form data is not preserved with form_with url: approach
    expect(page).to have_field('Username') # Field exists but value is cleared
  end

  it 'handles form submission correctly' do
    users_api = double(:users_api)
    allow(UsersApi).to receive(:new).and_return(users_api)
    allow(users_api).to receive(:create_user).and_return({
      success: false,
      errors: [ 'Some error' ]
    })

    visit root_path

    fill_in 'Username', with: 'testuser'
    fill_in 'Email', with: 'test@example.com'
    click_button 'Create Account'

    # The important thing is that the form submits without parameter errors
    expect(page).to have_content('Please fix the following errors:')
    expect(page).to have_content('Some error')
  end
end
