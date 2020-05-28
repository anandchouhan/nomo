class Post < ApplicationRecord
  belongs_to :user

  has_one :activity, as: :trackable, dependent: :destroy
  has_one_attached :picture

  enum privacy: %i(only_me friends friends_of_friends global)

  before_create :build_activity

  validates_presence_of :body, if: -> { !picture.attached? }
end
