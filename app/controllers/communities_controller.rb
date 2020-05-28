class CommunitiesController < ApplicationController
  def new
    @community = Community.new
  end

  def create
    @community = Community.create(community_params)

    if @community.save
      redirect_back(fallback_location: root_path, notice: "Community was successfully created.")
    end
  end

  private

  def community_params
    params.require(:community).permit(:name, :description, :user_id, :privacy)
  end
end
