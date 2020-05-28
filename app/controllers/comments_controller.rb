class CommentsController < ApplicationController
  include ActionView::Helpers::TextHelper

  after_action :create_notification, only: %i(create), if: -> { @comment.persisted? }

  def index
    if params[:activity_id].present?
      # List comments made in an activity, which means, using the feed.
      @activity = Activity.find(params[:activity_id])
      render partial: "comments/activity_comments", layout: false
    else
      @comments = current_trip.comments.order("created_at").reverse_order
    end
  end

  def new
    @comment = current_trip.comment.build
    respond_to do |format|
      format.js { NF.Comments.removeDuplicateDetails; }
    end
  end

  def show; end

  def create
    @comment = Comment.new
    @comment.user = current_user
    @comment.body = params[:comment][:body]

    if params[:activity_id].present?
      activity = Activity.find(params[:activity_id])
      @comment.commentable = activity
    elsif params[:trip_location_id].present?
      trip_location = TripLocation.find(params[:trip_location_id])
      @comment.commentable = trip_location
    end

    @comment.save
  end

  # DELETE /trips/1
  # DELETE /trips/1.json
  def destroy
    @comment = Comment.find(params[:id])
    @commentable = @comment.commentable
    @comment.destroy
    respond_to do |format|
      @comments = @commentable.comments
      format.js {}
      format.html { redirect_to profiles_url, notice: "Comment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def upvote
    @comment = Comment.find(params[:id])
    @comment.liked_by current_user
    render :vote
  end

  def downvote
    @comment = Comment.find(params[:id])
    @comment.unliked_by current_user
    render :vote
  end

  private

  def create_notification
    case @comment.commentable_type
    when "TripLocation"
      create_trip_location_notification
    when "Activity"
      create_activity_notification
    end
  end

  def create_trip_location_notification
    trip_location = TripLocation.find(@comment.commentable_id)
    heading = "You have a new comment from #{@comment.user.name} on the trip that you are attending to <a href=#{trip_trip_location_path(trip_location.trip, trip_location)}>#{trip_location.location.name}</a>"
    mobile_url = @comment.commentable.trip_location_comment_custom_email_html(@comment, "trip_location_comment")

    trip_location.participants.each do |user|
      unless current_user == user
        push_message = "You have a new comment from #{@comment.user.name} on the trip that you are attending to #{trip_location.location.name}"  
        Notification.create(heading: heading, recipient_user_id: user.id, sender_user_id: @comment.user.id, notify_type: "trip_location_comment", trip_location_id: trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_COMMENTS_ON_MY_ACTIVITY, context: mobile_url) 
        if user.ios_device_token.present?  
          device_token = user.ios_device_token
          type = "ios"
        else
          device_token = user.android_device_token
          type = "android"
        end
        data = { notify_type: "trip_location_comment", sender_user_id: @comment.user.id, recipient_user_id: user.id, trip_location_id: trip_location.id, trip_id: trip_location.trip.id, name: @comment.user.name, device_token: device_token, device_type: type, message: push_message }
        Notification.send_push_notification(data) if device_token.present?
      end
    end
  end

  def create_activity_notification
    if @comment.commentable.trackable_type == "TripLocation"
      trip_location_id = @comment.commentable.trackable_id
      trip_location = TripLocation.find(trip_location_id)
      heading = "You have a new comment from #{@comment.user.name} on the trip that you are attending to <a href=#{activity_path(@comment.commentable)}>#{trip_location.location.name}</a>"
      mobile_url = trip_location.trip_location_activity_custom_email_html(@comment, "activity_comment")
      unless current_user == trip_location.trip.user 
        Notification.create(heading: heading, recipient_user_id: trip_location.trip.user_id, sender_user_id: @comment.user_id, notify_type: "activity_comment", trip_location_id: trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_COMMENTS_ON_MY_ACTIVITY, context: mobile_url)
        push_message = "You have a new comment from #{@comment.user.name} on the trip that you are attending to #{trip_location.location.name}"
        if trip_location.trip.user.ios_device_token.present?  
          device_token = trip_location.trip.user.ios_device_token
          type = "ios"
        else
          device_token = trip_location.trip.user.android_device_token
          type = "android"
        end
        data = { notify_type: "activity_comment", sender_user_id: @comment.user_id, recipient_user_id: trip_location.trip.user_id, trip_location_id: trip_location.id, trip_id: trip_location.trip.id, name: @comment.user.name, device_token: device_token, device_type: type, message: push_message }
        Notification.send_push_notification(data) if device_token.present?
      end
    elsif @comment.commentable.trackable_type == "Post"
      post_id = @comment.commentable.trackable_id
      post = Post.find(post_id)
      heading = "You have a new comment from #{@comment.user.name} on your <a href=#{activity_path(@comment.commentable)}>post</a>"
      Notification.create(heading: heading, recipient_user_id: post.user_id, sender_user_id: @comment.user_id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_COMMENTS_ON_MY_ACTIVITY) unless current_user == post.user
    end
  end
end


