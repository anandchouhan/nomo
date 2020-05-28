# Activities are used to show entries in the feed.
# An activity can be a trip, a post, comment, polls and any other entities
# that should be tracked across the website.
class Activity < ApplicationRecord
  belongs_to :trackable, polymorphic: true

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
end
