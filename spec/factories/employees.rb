FactoryBot.define do
  factory :employee do
    sequence(:email) { |n| "test_employee_#{n}@example.com" }
  end
end
