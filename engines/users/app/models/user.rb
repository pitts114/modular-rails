# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_one :user_signup_info, dependent: :destroy

  validates :username, presence: true, uniqueness: true

  delegate :email, :phone_number, to: :user_signup_info, allow_nil: true
end
