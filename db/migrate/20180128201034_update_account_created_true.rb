class UpdateAccountCreatedTrue < ActiveRecord::Migration
  def change
    User.all.each do |u|
      w = Waitlist.where(email: u.email)
      if !w.empty? && w.first.position <= 0
        u.update_attributes(account_created: true)
      end
    end
  end
end
