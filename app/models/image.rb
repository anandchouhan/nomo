class Image < ApplicationRecord
  belongs_to :user
  belongs_to :trip_location

  validates :image_path, presence: true
end
