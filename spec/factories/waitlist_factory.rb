FactoryBot.define do
  factory :waitlist do
    email { Faker::Internet.email }
    position 10
  end
end
