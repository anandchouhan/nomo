class Travel < ApplicationRecord
  belongs_to :trip_location, inverse_of: :travels
  belongs_to :departure_location, class_name: :Location, foreign_key: :departure_location_id, optional: true
  belongs_to :arrival_location, class_name: :Location, foreign_key: :arrival_location_id, optional: true
  belongs_to :user, optional: true

  validates_presence_of :trip_location

  validate :valid_dates

  private

  def valid_dates
    if arriving_at.blank?
      errors.add(:arriving_at, "must not be empty")
    elsif departing_at.blank?
      errors.add(:departing_at, "must not be empty")
    elsif departing_at > arriving_at
      errors.add(:arriving_at, "must be greater or equal than departing at")
    end
  end
end
