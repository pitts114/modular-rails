require 'rails_helper'

RSpec.describe "Notifications Integration", type: :system do
  it "creates contact preferences when a user signs up" do
    # Visit the signup page
    visit root_path

    # Fill out the signup form
    fill_in 'user[username]', with: 'testuser'
    fill_in 'user[password]', with: 'password123'
    fill_in 'user[email]', with: 'test@example.com'
    fill_in 'user[phone_number]', with: '+1234567890'

    # Submit the form
    click_button 'Create Account'

    # Should be redirected to success page
    expect(page).to have_current_path(success_users_path)
    expect(page).to have_content('Account Created Successfully!', normalize_ws: true)

    # Now sign in
    visit login_users_path
    fill_in 'user[username]', with: 'testuser'
    fill_in 'user[password]', with: 'password123'
    click_button 'Sign In'

    # Should be on profile page
    expect(page).to have_current_path(profile_users_path)
    expect(page).to have_content('Welcome, testuser!')

    # Click on Contact Preferences link
    click_link 'Contact Preferences'

    # Should be on contact preferences page
    expect(page).to have_current_path(contact_preferences_path)
    expect(page).to have_content('Contact Preferences')

    # Should show the user's contact information
    expect(page).to have_content('test@example.com')
    expect(page).to have_content('+1234567890')
    expect(page).to have_content('Email Notifications: Enabled')
    expect(page).to have_content('Phone Notifications: Enabled')
  end

  it "allows users to edit their contact preferences" do
    # Create a user first
    users_api = UsersApi.new
    result = users_api.create_user(
      username: 'edituser',
      password: 'password123',
      email: 'edit@example.com',
      phone_number: '+1111111111'
    )

    # Ensure user was created successfully
    expect(result[:success]).to be true
    user = result[:user]

    # Verify contact preference was created via event processing
    notifications_api = NotificationsApi.new
    contact_pref_result = notifications_api.get_contact_preference(user_id: user.id)
    expect(contact_pref_result[:success]).to be(true), "Contact preference should be created automatically via event processing. Errors: #{contact_pref_result[:errors]}"

    # Sign in
    visit login_users_path
    fill_in 'user[username]', with: 'edituser'
    fill_in 'user[password]', with: 'password123'
    click_button 'Sign In'

    # Verify we're logged in
    expect(page).to have_current_path(profile_users_path)

    # Go to contact preferences
    visit contact_preferences_path

    # Should see the contact preference data
    expect(page).to have_content('edit@example.com')
    expect(page).to have_content('+1111111111')

    # Verify the page is properly loaded before trying to click the link
    expect(page).to have_content('Contact Preferences')
    expect(page).to have_content('Contact Information')

    # Try the content link first as it's only shown when contact preference exists
    if page.has_link?('Edit Preferences')
      click_link 'Edit Preferences'
    else
      # Fall back to the navigation link
      click_link 'Edit Contact Preferences'
    end

    # Should be on edit page
    expect(page).to have_current_path(edit_contact_preferences_path)
    expect(page).to have_content('Edit Contact Preferences')

    # Edit the preferences
    fill_in 'contact_preference[email]', with: 'newemail@example.com'
    fill_in 'contact_preference[phone_number]', with: '+9999999999'
    uncheck 'contact_preference[email_notifications_enabled]'
    check 'contact_preference[phone_notifications_enabled]'

    # Submit the form
    click_button 'Update Preferences'

    # Should be redirected back to show page
    expect(page).to have_current_path(contact_preferences_path)
    expect(page).to have_content('Contact preferences updated successfully!')

    # Should show updated information
    expect(page).to have_content('newemail@example.com')
    expect(page).to have_content('+9999999999')
    expect(page).to have_content('Email Notifications: Disabled')
    expect(page).to have_content('Phone Notifications: Enabled')
  end
end
