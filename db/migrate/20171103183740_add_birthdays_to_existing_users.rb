class AddBirthdaysToExistingUsers < ActiveRecord::Migration
  def change
    nobirthday = User.where(date_of_birth: nil)
    nobirthday.each do |x|
      x.update(date_of_birth: "1/1/1990")
    end
  end
end
