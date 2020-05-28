class UpdateReferralLink < ActiveRecord::Migration
  def change
    Waitlist.find_each do |w|
      w.referral_link = "https://www.nomo-fomo.com/referral/#{w.id}"
      w.save!
    end
  end
end
