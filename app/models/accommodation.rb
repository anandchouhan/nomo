class Accommodation < ApplicationRecord
  belongs_to :trip_location, inverse_of: :accommodations
  belongs_to :location, optional: true
  belongs_to :user, optional: true

  validates_presence_of :trip_location, :name
  validate :valid_dates

  private
  
  def valid_dates
    if arriving_at.blank?
      errors.add(:arriving_at, "must not be empty")
    elsif departing_at.blank?
      errors.add(:departing_at, "must not be empty")
    elsif arriving_at > departing_at
      errors.add(:departing_at, "must be greater or equal than arriving at")
    end
  end
end
