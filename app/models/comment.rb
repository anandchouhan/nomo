class Comment < ApplicationRecord
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper

  acts_as_votable

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates_presence_of :body
  validates_presence_of :user

  after_create_commit :broadcast

  def text
    body
  end

  private

  # Broadcasts necessary information to subscibers using ActionCable.
  def broadcast
    # As the view 'trip_locations/_comment' depends on the current_user to be rendered,
    # and the current_user doesn't make sense using ActionCable because many users can be connected to the same channel,
    # this workaround is used.
    #
    # It renders the same comment over and over again, regardless current_user,
    # but this render should be done on the client side using JavaScript.
    # Its's done this way due to time constraints.
    if commentable_type == "TripLocation"
      comment = self
      view = TripLocationsController.render :_comment_actioncable, locals: { comment: comment }, layout: false
      comment_json = comment.as_json.merge(name: user.name, profile_image: user.picture)
      Struct.new("Response", :action, :id, :view, :comment_json)
      response = Struct::Response.new("new_comment", id, view, comment_json)

      TripLocationChannel.broadcast_to(commentable, response)
    end
  end
end
