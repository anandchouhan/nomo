class Event < ApplicationRecord
  belongs_to :trip_location, inverse_of: :events
  belongs_to :location, optional: true
  belongs_to :user, optional: true

  validates_presence_of :trip_location
  validate :valid_dates

  private

  def valid_dates
    if start_at.blank?
      errors.add(:start_at, "must not be empty")
    elsif end_at.blank?
      errors.add(:end_at, "must not be empty")
    elsif start_at > end_at
      errors.add(:end_at, "must be greater or equal than start at")
    end
  end
end
