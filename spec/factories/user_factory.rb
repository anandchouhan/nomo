FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password "password123"
    password_confirmation "password123"
    date_of_birth Faker::Date.between(70.years.ago, 18.years.ago)
    encrypted_password { Devise::Encryptor.digest(User, "Pass$123") }
    viewed_walkthrough 1

    trait :with_location_and_hometown do
      location
      hometown { location }
    end
  end
end
