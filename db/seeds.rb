Waitlist.find_or_create_by!(email: "user_one@email.com") do |waitlist|
  waitlist.position = 0
end

Waitlist.find_or_create_by!(email: "user_two@email.com") do |waitlist|
  waitlist.position = 0
end

Waitlist.find_or_create_by!(email: "user_three@email.com") do |waitlist|
  waitlist.position = 0
end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or find_or_create_by alongside the db with db:setup).

AdminUser.create!(email: "admin@example.com", password: "password", password_confirmation: "password") if Rails.env.development?