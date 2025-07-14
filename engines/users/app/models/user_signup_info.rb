# frozen_string_literal: true

class UserSignupInfo < ApplicationRecord
  belongs_to :user

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, format: { with: /\A\+?[\d\s\-\(\)]+\z/, allow_blank: true }
end
