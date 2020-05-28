class CreateWaitlistForUsers < ActiveRecord::Migration
  def change
    users = User.all
    users.each do |user|
      Waitlist.find_or_create_by!(email: user.email) do |waitlist|
        waitlist.position = 0
      end
    end
  end
end
