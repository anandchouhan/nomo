class PostsController < ApplicationController
  def create
    post = Post.new(post_params)
    post.user = current_user
    post.privacy = params[:privacy].to_i

    if post.save
      redirect_back fallback_location: root_path, notice: "The post was successfully created"
    else
      redirect_back fallback_location: root_path, notice: "There was an error creating the post"
    end
  end

  private

  def post_params
    params.permit(:body, :picture)
  end
end
