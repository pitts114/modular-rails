# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/login.html.erb', type: :view do
  context 'when there are no errors' do
    before do
      assign(:errors, nil)
      render
    end

    it 'displays the login form title' do
      expect(rendered).to include('Sign In')
    end

    it 'renders a form that posts to authenticate_users_path' do
      expect(rendered).to have_selector('form[action="/users/authenticate"][method="post"]')
    end

    it 'includes username field' do
      expect(rendered).to have_field('user[username]', type: 'text')
      expect(rendered).to have_selector('label[for="user_username"]', text: 'Username')
    end

    it 'includes password field' do
      expect(rendered).to have_field('user[password]', type: 'password')
      expect(rendered).to have_selector('label[for="user_password"]', text: 'Password')
    end

    it 'includes submit button' do
      expect(rendered).to have_button('Sign In')
    end

    it 'requires both fields' do
      expect(rendered).to have_selector('input[name="user[username]"][required]')
      expect(rendered).to have_selector('input[name="user[password]"][required]')
    end

    it 'includes link to signup page' do
      expect(rendered).to have_link('Sign up here', href: '/')
    end

    it 'does not display error messages' do
      expect(rendered).not_to include('Please fix the following errors:')
    end
  end

  context 'when there are authentication errors' do
    let(:errors) { [ 'Invalid username or password' ] }

    before do
      assign(:errors, errors)
      render
    end

    it 'displays error messages' do
      expect(rendered).to include('Please fix the following errors:')
      expect(rendered).to include('Invalid username or password')
    end

    it 'displays error in a list item' do
      expect(rendered).to have_selector('li', text: 'Invalid username or password')
    end

    it 'still displays the form' do
      expect(rendered).to have_selector('form[action="/users/authenticate"][method="post"]')
      expect(rendered).to have_field('user[username]')
      expect(rendered).to have_field('user[password]')
    end
  end

  context 'form parameter structure' do
    before do
      assign(:errors, nil)
      render
    end

    it 'generates form fields with correct nested parameter names' do
      expect(rendered).to have_selector('input[name="user[username]"]')
      expect(rendered).to have_selector('input[name="user[password]"]')
    end

    it 'does not generate flat parameter names' do
      expect(rendered).not_to have_selector('input[name="username"]')
      expect(rendered).not_to have_selector('input[name="password"]')
    end
  end
end
