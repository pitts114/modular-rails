# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Signup Full Integration', type: :system do
  before do
    driven_by(:rack_test)
  end

  it 'successfully creates a user through the complete flow' do
    visit root_path

    # Fill out the form
    fill_in 'Username', with: 'integration_test_user'
    fill_in 'Password', with: 'password123'
    fill_in 'Email', with: 'integration@example.com'
    fill_in 'Phone Number (optional)', with: '555-1234'

    # Submit the form
    click_button 'Create Account'

    # Verify we're on the success page
    expect(page).to have_content('Account Created Successfully!')
    expect(page).to have_content('Welcome!')

    # Verify the user was actually created in the database
    user = User.find_by(username: 'integration_test_user')
    expect(user).to be_present
    expect(user.authenticate('password123')).to be_truthy

    # Verify the signup info was created with email
    signup_info = UserSignupInfo.find_by(user_id: user.id)
    expect(signup_info).to be_present
    expect(signup_info.email).to eq('integration@example.com')
    expect(signup_info.phone_number).to eq('555-1234')
  end

  it 'displays real validation errors for duplicate username' do
    # Create an existing user with signup info
    user = User.create!(
      username: 'existing_user',
      password: 'password123'
    )
    UserSignupInfo.create!(
      user: user,
      email: 'existing@example.com'
    )

    visit root_path

    # Try to create a user with the same username
    fill_in 'Username', with: 'existing_user'
    fill_in 'Password', with: 'password123'
    fill_in 'Email', with: 'different@example.com'
    fill_in 'Phone Number (optional)', with: '555-1234'

    click_button 'Create Account'

    # Should stay on the form and show real validation errors
    expect(page).to have_content('Please fix the following errors:')
    expect(page).to have_content('Username has already been taken')
  end
end
