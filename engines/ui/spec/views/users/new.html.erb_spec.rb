# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/new.html.erb', type: :view do
  context 'when there are no errors' do
    before do
      assign(:errors, nil)
      render
    end

    it 'displays the signup form title' do
      expect(rendered).to include('Create Your Account')
    end

    it 'renders a form that posts to users_path' do
      expect(rendered).to have_selector('form[action="/users"][method="post"]')
    end

    it 'includes username field' do
      expect(rendered).to have_field('user[username]', type: 'text')
      expect(rendered).to have_selector('label[for="user_username"]', text: 'Username')
    end

    it 'includes password field' do
      expect(rendered).to have_field('user[password]', type: 'password')
      expect(rendered).to have_selector('label[for="user_password"]', text: 'Password')
    end

    it 'includes email field' do
      expect(rendered).to have_field('user[email]', type: 'email')
      expect(rendered).to have_selector('label[for="user_email"]', text: 'Email')
    end

    it 'includes phone number field' do
      expect(rendered).to have_field('user[phone_number]', type: 'tel')
      expect(rendered).to have_selector('label[for="user_phone_number"]', text: 'Phone Number (optional)')
    end

    it 'includes submit button' do
      expect(rendered).to have_button('Create Account')
    end

    it 'requires required fields' do
      expect(rendered).to have_selector('input[name="user[username]"][required]')
      expect(rendered).to have_selector('input[name="user[password]"][required]')
      expect(rendered).to have_selector('input[name="user[email]"][required]')
      expect(rendered).to have_selector('input[name="user[phone_number]"]:not([required])')  # Phone is optional
    end

    it 'does not display error messages' do
      expect(rendered).not_to include('Please fix the following errors:')
    end

    it 'includes link to login page' do
      expect(rendered).to have_link('Sign In', href: login_users_path)
      expect(rendered).to include('Already have an account?')
    end
  end

  context 'when there are validation errors' do
    let(:errors) { [ 'Username is already taken', 'Email is invalid' ] }

    before do
      assign(:errors, errors)
      render
    end

    it 'displays error messages' do
      expect(rendered).to include('Please fix the following errors:')
      expect(rendered).to include('Username is already taken')
      expect(rendered).to include('Email is invalid')
    end

    it 'displays each error in a list item' do
      expect(rendered).to have_selector('li', text: 'Username is already taken')
      expect(rendered).to have_selector('li', text: 'Email is invalid')
    end

    it 'still displays the form' do
      expect(rendered).to have_selector('form[action="/users"][method="post"]')
      expect(rendered).to have_field('user[username]')
      expect(rendered).to have_field('user[password]')
    end
  end

  context 'when errors is an empty array' do
    before do
      assign(:errors, [])
      render
    end

    it 'does not display error messages' do
      expect(rendered).not_to include('Please fix the following errors:')
    end
  end

  context 'form parameter structure' do
    before do
      assign(:errors, nil)
      render
    end

    it 'generates form fields with correct nested parameter names' do
      # This test would have caught the missing scope: :user issue
      expect(rendered).to have_selector('input[name="user[username]"]')
      expect(rendered).to have_selector('input[name="user[password]"]')
      expect(rendered).to have_selector('input[name="user[email]"]')
      expect(rendered).to have_selector('input[name="user[phone_number]"]')
    end

    it 'does not generate flat parameter names' do
      # Ensure we're not accidentally using flat parameter names (which would cause the error)
      expect(rendered).not_to have_selector('input[name="username"]')
      expect(rendered).not_to have_selector('input[name="password"]')
      expect(rendered).not_to have_selector('input[name="email"]')
      expect(rendered).not_to have_selector('input[name="phone_number"]')
    end
  end
end
