class Community < ApplicationRecord
  belongs_to :user
  has_many :events
  
  has_one :community_privacy_settings
  before_create :set_default_privacy_settings

  attr_accessor :privacy

  private

  def set_default_privacy_settings
    build_community_privacy_settings(community_id: id, see_community_and_request_to_join: privacy)
    true
  end
end
