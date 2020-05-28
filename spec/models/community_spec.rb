require "rails_helper"

RSpec.describe Community, type: :model do
  it { should belong_to(:user) }

  it { should have_one(:community_privacy_settings) }
end
