# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/success.html.erb', type: :view do
  before do
    render
  end

  it 'displays success title' do
    expect(rendered).to include('🎉 Account Created Successfully!')
  end

  it 'displays welcome message' do
    expect(rendered).to include('Welcome! Your account has been created and you\'re all set to get started.')
  end

  it 'displays sign in instruction' do
    expect(rendered).to include('You can now use your username and password to sign in.')
  end

  it 'includes a link to home page' do
    expect(rendered).to have_link('Go to Home', href: '/')
  end

  it 'applies success styling classes' do
    expect(rendered).to have_selector('.success-container')
    expect(rendered).to have_selector('.success-message')
    expect(rendered).to have_selector('.next-steps')
  end
end
