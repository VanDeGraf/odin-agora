FactoryBot.define do
  factory :user do
    # first_name { Faker::Name.first_name }
    # last_name { Faker::Name.last_name }
    # sex { Faker::Number.between(from: 0, to: 2) }
    # birthday { Faker::Date.birthday(min_age: 18, max_age: 65) }
    email { Faker::Internet.safe_email }
    password { '123456' }
    # encrypted_password { User.new(password: '123456').encrypted_password }
  end
end
