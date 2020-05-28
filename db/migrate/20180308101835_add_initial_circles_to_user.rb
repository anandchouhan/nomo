class AddInitialCirclesToUser < ActiveRecord::Migration
  def change
    User.all.each do |user|
      user.circles.find_or_create_by(name: :default, created_by_system: true)
      user.circles.find_or_create_by(name: :prioritization, created_by_system: true)
      user.circles.find_or_create_by(name: :stop_following, created_by_system: true)
    end
  end
end
