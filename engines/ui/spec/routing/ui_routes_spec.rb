# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UI Routes', type: :routing do
  it 'routes root to signup form' do
    expect(get: '/').to route_to(controller: 'users', action: 'new')
  end

  it 'routes GET /users/new to signup form' do
    expect(get: '/users/new').to route_to(controller: 'users', action: 'new')
  end

  it 'routes POST /users to create action' do
    expect(post: '/users').to route_to(controller: 'users', action: 'create')
  end

  it 'routes GET /users/success to success page' do
    expect(get: '/users/success').to route_to(controller: 'users', action: 'success')
  end

  it 'routes GET /users/login to login action' do
    expect(get: '/users/login').to route_to(controller: 'users', action: 'login')
  end

  it 'routes POST /users/authenticate to authenticate action' do
    expect(post: '/users/authenticate').to route_to(controller: 'users', action: 'authenticate')
  end

  it 'routes GET /users/profile to profile action' do
    expect(get: '/users/profile').to route_to(controller: 'users', action: 'profile')
  end

  it 'routes DELETE /users/logout to logout action' do
    expect(delete: '/users/logout').to route_to(controller: 'users', action: 'logout')
  end
end
