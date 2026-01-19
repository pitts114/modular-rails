require 'rails_helper'

RSpec.describe "contact_preferences/show", type: :view do
  let(:profile) do
    double(:profile,
      email: 'test@example.com',
      phone_number: '+1234567890'
    )
  end

  let(:contact_preference) do
    double(:contact_preference,
      email_notifications_enabled?: true,
      phone_notifications_enabled?: false
    )
  end

  before do
    assign(:profile, profile)
    assign(:contact_preference, contact_preference)
    assign(:errors, nil)
  end

  it 'displays the contact preference information' do
    render

    expect(rendered).to have_content('Contact Preferences')
    expect(rendered).to have_content('test@example.com')
    expect(rendered).to have_content('+1234567890')
    expect(rendered).to have_content('Enabled')
    expect(rendered).to have_content('Disabled')
  end

  it 'shows edit preferences link' do
    render

    expect(rendered).to have_link('Edit Preferences', href: edit_contact_preferences_path)
    expect(rendered).to have_link('Edit Contact Preferences', href: edit_contact_preferences_path)
  end

  it 'shows navigation links' do
    render

    expect(rendered).to have_link('Profile', href: profile_users_path)
  end

  it 'displays contact information section' do
    render

    expect(rendered).to have_content('Contact Information')
    expect(rendered).to have_content('Email: test@example.com')
    expect(rendered).to have_content('Phone Number: +1234567890')
  end

  it 'displays notification preferences section' do
    render

    expect(rendered).to have_content('Notification Preferences')
    expect(rendered).to have_content('Email Notifications: Enabled')
    expect(rendered).to have_content('Phone Notifications: Disabled')
  end

  context 'when phone number is not provided' do
    let(:profile) do
      double(:profile,
        email: 'test@example.com',
        phone_number: nil
      )
    end

    let(:contact_preference) do
      double(:contact_preference,
        email_notifications_enabled?: true,
        phone_notifications_enabled?: true
      )
    end

    it 'displays "Not provided" for missing phone number' do
      render

      expect(rendered).to have_content('Phone Number: Not provided')
    end
  end

  context 'when profile or contact preference is nil' do
    before do
      assign(:profile, nil)
      assign(:contact_preference, nil)
      assign(:errors, [ 'Contact preference not found' ])
    end

    it 'displays error message' do
      render

      expect(rendered).to have_content('No contact preferences found')
      expect(rendered).to have_content('This should have been created when your account was set up')
    end
  end

  context 'with flash messages' do
    it 'displays success notice' do
      flash[:notice] = 'Preferences updated successfully!'
      render

      expect(rendered).to have_content('Preferences updated successfully!')
      expect(rendered).to have_css('.alert-success')
    end

    it 'displays error alert' do
      flash[:alert] = 'Something went wrong'
      render

      expect(rendered).to have_content('Something went wrong')
      expect(rendered).to have_css('.alert-danger')
    end
  end

  context 'with errors' do
    before do
      assign(:errors, [ 'Email is invalid', 'Phone number is required' ])
    end

    it 'displays error messages' do
      render

      expect(rendered).to have_content('Email is invalid')
      expect(rendered).to have_content('Phone number is required')
      expect(rendered).to have_css('.alert-danger')
    end
  end
end
