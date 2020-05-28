class Whitelist < ApplicationRecord
  scope :activated, -> { where(event: :reservation_activated) }
end
