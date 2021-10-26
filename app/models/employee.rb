class Employee < ApplicationRecord
  include JWT::Authenticatable

  validates :email, presence: true, uniqueness: true, format: URI::MailTo::EMAIL_REGEXP
end
