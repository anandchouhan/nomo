require "csv"
namespace :import_waitlisted do
  desc "Imports waitlist"
  task create_waitlists: [:environment] do
    CSV.foreach("lib/seeds/waitlisted.csv", headers: true) do |row|
      row_hash = row.to_hash
      position = row_hash["current_position"]
      if position == "Activated"
        Waitlist.find_or_create_by!(email: row_hash["email"]) do |waitlist|
          waitlist.position = 200
          waitlist.referred_by = row_hash["referred_by_email"]
        end
      else
        Waitlist.find_or_create_by!(email: row_hash["email"]) do |waitlist|
          waitlist.position = position.to_i + 200
          waitlist.referred_by = row_hash["referred_by_email"]
        end
      end
    end
  end
end
