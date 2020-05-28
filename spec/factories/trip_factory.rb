FactoryBot.define do
  factory :trip do
    name { Faker::StarWars.planet }
    start_at { 30.days.from_now }
    end_at { 40.days.from_now }
    location
    user
  end
end
