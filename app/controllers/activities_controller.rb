class ActivitiesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_current_user

  def index
    gon.appId = ENV["FACEBOOK_APP_ID"]

    @filter = params[:filter]
    if @filter != "friends-of-friends" && @filter != "friends"
      @filter = "public"
    end

    @activities = next_activities_batch(0, @filter)
    render :index
  end

  def show
    @activity = Activity.find_by_id(params[:id])
    if @activity.nil?
      redirect_to root_url, notice: "Activity not found"
    end
  end

  # Called when an Ajax request is made to retrieve the next batch of activities
  def scroll_refresh
    @activities = next_activities_batch(params[:offset], params[:filter])
  end

  private

  # Returns the next batch of activities, limiting 20 per batch starting on offset.
  # Activities are filtered depending on user's choice.
  # Public filter shows all trips where privacy is different from Private.
  # Friends of friends filter shows all trips where the current user has a friend in common with the trip's owner, plus current user's friends.
  # Friends filter only shows friends' trips.
  def next_activities_batch(offset, filter)
    user_trips = <<-SQL
      SELECT activities.id
      FROM activities
      INNER JOIN trip_locations ON trip_locations.id = activities.trackable_id
      INNER JOIN trips ON trips.id = trip_locations.trip_id
      WHERE activities.trackable_type = 'TripLocation' AND trips.user_id = :user_id\n
    SQL

    user_posts = <<-SQL
      SELECT activities.id
      FROM activities
      INNER JOIN posts ON posts.id = activities.trackable_id
      WHERE activities.trackable_type = 'Post' AND posts.user_id = :user_id\n
    SQL

    public_trips = <<-SQL
      SELECT activities.id
      FROM activities
      INNER JOIN trip_locations ON trip_locations.id = activities.trackable_id
      INNER JOIN trips ON trips.id = trip_locations.trip_id
      WHERE activities.trackable_type = 'TripLocation' AND trips.privacy_settings = 'Public'\n
    SQL

    public_posts = <<-SQL
      SELECT activities.id
      FROM activities
      INNER JOIN posts ON posts.id = activities.trackable_id
      WHERE activities.trackable_type = 'Post' AND posts.privacy = 3\n
    SQL

    friends_of_friends_trips = <<-SQL
      SELECT activities.id
      FROM friendships AS first_grade_friendships
      INNER JOIN friendships AS second_grade_friendships ON first_grade_friendships.destination_user_id = second_grade_friendships.destination_user_id
      INNER JOIN trips ON trips.user_id = second_grade_friendships.origin_user_id
      INNER JOIN trip_locations ON trip_locations.trip_id = trips.id
      INNER JOIN activities ON activities.trackable_id = trip_locations.id
      WHERE activities.trackable_type = 'TripLocation'
      AND trips.privacy_settings IN ('FriendsOfFriends', 'Public') AND first_grade_friendships.origin_user_id = :user_id\n
    SQL

    friends_of_friends_posts = <<-SQL
      SELECT activities.id
      FROM friendships AS first_grade_friendships
      INNER JOIN friendships AS second_grade_friendships ON first_grade_friendships.destination_user_id = second_grade_friendships.destination_user_id
      INNER JOIN posts ON posts.user_id = second_grade_friendships.origin_user_id
      INNER JOIN activities ON activities.trackable_id = posts.id
      WHERE activities.trackable_type = 'Post'
      AND posts.privacy IN (2, 3) AND first_grade_friendships.origin_user_id = :user_id\n
    SQL

    friends_trips = <<-SQL
      SELECT activities.id
      FROM activities
      INNER JOIN trip_locations ON trip_locations.id = activities.trackable_id
      INNER JOIN trips ON trips.id = trip_locations.trip_id
      INNER JOIN friendships ON friendships.destination_user_id = trips.user_id
      WHERE activities.trackable_type = 'TripLocation'
      AND trips.privacy_settings IN ('MyNetwork', 'FriendsOfFriends', 'Public') AND friendships.origin_user_id = :user_id\n
    SQL

    friends_posts = <<-SQL
      SELECT activities.id
      FROM activities
      INNER JOIN posts ON posts.id = activities.trackable_id
      INNER JOIN friendships ON friendships.destination_user_id = posts.user_id
      WHERE activities.trackable_type = 'Post'
      AND posts.privacy IN (1, 2, 3) AND friendships.origin_user_id = :user_id\n
    SQL

    sql = "SELECT DISTINCT activities.* FROM activities WHERE id IN (#{user_trips} UNION #{user_posts} UNION #{public_trips} UNION #{public_posts} UNION #{friends_of_friends_trips} UNION #{friends_of_friends_posts} UNION #{friends_trips} UNION #{friends_posts}) ORDER BY created_at DESC LIMIT 20 OFFSET :offset"
    if filter == "friends-of-friends"
      sql = "SELECT DISTINCT activities.* FROM activities WHERE id IN (#{user_trips} UNION #{user_posts} UNION #{friends_of_friends_trips} UNION #{friends_of_friends_posts} UNION #{friends_trips} UNION #{friends_posts}) ORDER BY created_at DESC LIMIT 20 OFFSET :offset"
    elsif filter == "friends"
      sql = "SELECT DISTINCT activities.* FROM activities WHERE id IN (#{user_trips} UNION #{user_posts} UNION #{friends_trips} UNION #{friends_posts}) ORDER BY created_at DESC LIMIT 20 OFFSET :offset"
    end

    Activity.find_by_sql [sql, { user_id: current_user.id, offset: offset }]
  end
end
