require 'rails_helper'

RSpec.describe "contact_preferences/edit", type: :view do
  let(:contact_preference) do
    double(:contact_preference,
      email: 'test@example.com',
      phone_number: '+1234567890',
      email_notifications_enabled: true,
      phone_notifications_enabled: false
    )
  end

  before do
    assign(:contact_preference, contact_preference)
    assign(:errors, nil)
  end

  it 'displays the edit form with correct action' do
    render

    expect(rendered).to have_css("form[action='#{contact_preferences_path}'][method='post']")
    expect(rendered).to have_css("input[name='_method'][value='patch']", visible: false)
  end

  it 'generates form fields with correct nested parameter names' do
    render

    expect(rendered).to have_field('contact_preference[email]', with: 'test@example.com')
    expect(rendered).to have_field('contact_preference[phone_number]', with: '+1234567890')
    expect(rendered).to have_field('contact_preference[email_notifications_enabled]', checked: true)
    expect(rendered).to have_field('contact_preference[phone_notifications_enabled]', checked: false)
  end

  it 'has required email field' do
    render

    expect(rendered).to have_field('contact_preference[email]', type: 'email')
    expect(rendered).to have_css('input[name="contact_preference[email]"][required]')
  end

  it 'has telephone field for phone number' do
    render

    expect(rendered).to have_field('contact_preference[phone_number]', type: 'tel')
    expect(rendered).to have_css('input[placeholder="+1234567890"]')
  end

  it 'has checkbox fields for notification preferences' do
    render

    expect(rendered).to have_field('contact_preference[email_notifications_enabled]', type: 'checkbox')
    expect(rendered).to have_field('contact_preference[phone_notifications_enabled]', type: 'checkbox')
  end

  it 'displays section headers' do
    render

    expect(rendered).to have_content('Edit Contact Preferences')
    expect(rendered).to have_content('Contact Information')
    expect(rendered).to have_content('Notification Preferences')
  end

  it 'displays field labels' do
    render

    expect(rendered).to have_content('Email Address')
    expect(rendered).to have_content('Phone Number')
    expect(rendered).to have_content('Send me email notifications')
    expect(rendered).to have_content('Send me SMS notifications')
  end

  it 'has submit button and cancel link' do
    render

    expect(rendered).to have_button('Update Preferences')
    expect(rendered).to have_link('Cancel', href: contact_preferences_path)
  end

  it 'shows navigation links' do
    render

    expect(rendered).to have_link('View Preferences', href: contact_preferences_path)
    expect(rendered).to have_link('Profile', href: profile_users_path)
  end

  context 'when contact preference has blank phone number' do
    let(:contact_preference) do
      double(:contact_preference,
        email: 'test@example.com',
        phone_number: '',
        email_notifications_enabled: true,
        phone_notifications_enabled: true
      )
    end

    it 'displays empty phone number field' do
      render

      expect(rendered).to have_field('contact_preference[phone_number]', with: '')
    end
  end

  context 'when contact preference has nil phone number' do
    let(:contact_preference) do
      double(:contact_preference,
        email: 'test@example.com',
        phone_number: nil,
        email_notifications_enabled: true,
        phone_notifications_enabled: true
      )
    end

    it 'displays empty phone number field for nil value' do
      render

      expect(rendered).to have_field('contact_preference[phone_number]')
      # For nil values, the field will be empty (no value attribute)
      expect(rendered).to have_css('input[name="contact_preference[phone_number]"]')
    end
  end

  context 'with validation errors' do
    before do
      assign(:errors, [ 'Email is invalid', 'Phone number format is incorrect' ])
    end

    it 'displays error messages' do
      render

      expect(rendered).to have_content('Please fix the following errors:')
      expect(rendered).to have_content('Email is invalid')
      expect(rendered).to have_content('Phone number format is incorrect')
      expect(rendered).to have_css('.alert-danger')
    end
  end

  context 'when contact preference is nil' do
    before do
      assign(:contact_preference, nil)
    end

    it 'handles nil contact preference gracefully' do
      render

      expect(rendered).to have_field('contact_preference[email]')
      expect(rendered).to have_field('contact_preference[phone_number]')
      expect(rendered).to have_field('contact_preference[email_notifications_enabled]', checked: false)
      expect(rendered).to have_field('contact_preference[phone_notifications_enabled]', checked: false)

      # Check that the form fields exist even with nil contact preference
      expect(rendered).to have_css('input[name="contact_preference[email]"]')
      expect(rendered).to have_css('input[name="contact_preference[phone_number]"]')
    end
  end

  it 'uses proper CSS classes for styling' do
    render

    expect(rendered).to have_css('.container')
    expect(rendered).to have_css('.form-section')
    expect(rendered).to have_css('.form-group')
    expect(rendered).to have_css('.btn-primary')
    expect(rendered).to have_css('.btn-secondary')
  end

  it 'includes proper form scope' do
    render

    # The form should use scope: :contact_preference to create proper parameter nesting
    expect(rendered).to match(/name="contact_preference\[/)
  end
end
