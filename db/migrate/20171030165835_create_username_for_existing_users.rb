class CreateUsernameForExistingUsers < ActiveRecord::Migration
  def change
    nonames = User.where(username: nil)
    nonames.each do |x|
      if User.where(username: x.name.gsub(" ", "_").downcase).exists? == true
        n = 0
        loop do
          n = n + 1
          uniqname = x.name.gsub(" ", "_").downcase + n.to_s
          break if User.where(username: uniqname).exists? == false
        end
        x.update(username: x.name.gsub(" ", "_").downcase + n.to_s)
      else
        x.update(username: x.name.gsub(" ", "_").downcase)
      end
    end
  end
end
