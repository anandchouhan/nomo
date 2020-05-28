Rails.application.routes.draw do
  # devise_for :admin_users, ActiveAdmin::Devise.config
  # ActiveAdmin.routes(self)
  
  root "static_pages#index"
  get "referral/:referrer_id" => "users#index"
  mount ActionCable.server, at: "/cable"
  devise_for :users, controllers: {
    omniauth_callbacks: "omniauth_callbacks",
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  namespace :api, defaults: { format: "json" } do
    resources :base
    post "users/sign_in", to: "sessions#create", as: :sign_in
    post "users/forgot_password", to: "passwords#create", as: :forgot_password
    put "users/password", to: "passwords#update", as: :password
    post "users/sign_up", to: "registrations#create", as: :sign_up
    put "users/update", to: "registrations#update", as: :update
    put "users/update_facebook_id", to: "registrations#update_facebook_id"
    post "analytics", to: "registrations#analytics" 
    post "users/social_login", to: "omniauth_callbacks#create", as: :social_login
    post "users/check_facebook_id", to: "omniauth_callbacks#check_facebook_id"
    get "default_settings_data", to: "users#default_settings_data", as: :default_settings_data
    get "user_detail", to: "users#user_detail"
    get "user_trips/:user_id", to: "users#user_trips"
    put "enable_email_notification", to: "users#enable_email_notification"
    get "user_notifications", to: "users#user_notifications"
    put "update_device_token", to: "users#update_device_token"
    put "analytics_auth", to: "users#analytics_auth"
    put "mobile_notification_count", to: "users#mobile_notification_count"
    get "get_friends_list/my_friends", to: "find_friends#my_friends"
    get "get_friends_list/facebook_friends", to: "find_friends#facebook_friends"
    post "send_friend_request", to: "find_friends#send_friend_request"
    post "accept_friend_request", to: "find_friends#accept_friend_request"
    delete "request_for_remove_friends", to: "find_friends#destroy"
    get "search_friends", to: "find_friends#search_friends"
    get "trip_list", to: "trips#trip_list"
    get "trip_comments/:trip_location_id", to: "trips#trip_comments"
    get "trip_detail/:trip_location_id", to: "trips#trip_detail"
    get "trip_participants/:trip_location_id", to: "trip_locations#trip_participants"
    delete "remove_participant_from_trip", to: "trip_locations#remove_participant_from_trip"
    get "pending_requests_to_join_trip/:trip_location_id", to: "trip_locations#pending_requests_to_join_trip"
    delete "decline_request_to_join_trip", to: "trip_locations#decline_request_to_join_trip"
    post "accept_requests_to_join_trip", to: "trip_locations#accept_requests_to_join_trip"
    post "send_invite_request", to: "trip_locations#send_invite_request"
    get "trip_overlapping/:trip_location_id", to: "trip_locations#trip_overlapping"
    get "trip_lookup", to: "trip_locations#trip_lookup"
    post "add_comment", to: "trip_locations#create_trip_comments"
    post "trip_join_request", to: "trip_locations#trip_join_request"
    post "accept_invite_request", to: "trip_locations#accept_invite_request"
    delete "reject_invite_request", to: "trip_locations#reject_invite_request"
    post "trip_image", to: "trip_locations#trip_image"
    get "pending_invite_trip_requests/:trip_location_id", to: "trip_locations#pending_invite_trip_requests"
    post "trip_location_chat", to: "trip_locations#trip_location_chat"
    get "comment_list/:trip_location_id", to: "trip_locations#comment_list"
    delete "delete_trip_image", to: "trip_locations#delete_trip_image"
    delete "report_trip_image", to: "trip_locations#report_trip_image"
    delete "remove_from_trip", to: "trip_locations#remove_from_trip"
    post "create_trip", to: "trips#create"
    put "update_trip", to: "trips#update"
    delete "delete_trip", to: "trips#destroy"
    post "create_accommodation", to: "accommodations#create"
    put "update_accommodation", to: "accommodations#update"
    delete "delete_accommodation", to: "accommodations#destroy"
    post "create_travel", to: "travels#create"
    put "update_travel", to: "travels#update"
    delete "delete_travel", to: "travels#destroy"
    post "create_event", to: "events#create"
    put "update_event", to: "events#update"
    delete "delete_event", to: "events#destroy"
    post "like", to: "likes#create"
    delete "unlike", to: "likes#destroy"
  end

  get "explorer", to: "users#explorer"

  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: redirect("/")

  get "connect" => "users#connect"
  get "search_friends/:provider" => "users#search_connected_friends"
  post "contact_us" => "application#contact_us"
  get "unlink/:provider" => "users#unlink"

  get "sign_out" => "application#sign_out"

  get "waitlists/landing" => "waitlists#landing"
  get "reset_mobile_password" => "static_pages#reset_mobile_password"
  get "mobile_notification" => "static_pages#mobile_notification"
  resources :waitlists, only: %i(index show new)
  post "waitlists/create", to: "waitlists#create", as: "join_waitlist"
  post "waitlists/create_appsecret_proof" => "waitlists#create_appsecret_proof"
  post "waitlists/check_waitlist_position" => "waitlists#check_waitlist_position"
  get "check_position", to: "waitlists#check_position", as: "check_position"
  get "about" => "static_pages#about"
  get "terms-and-conditions" => "static_pages#terms_and_conditions"
  get "privacy" => "static_pages#privacy_policy"
  get "/welcome" => "onboardings#welcome"
  get "/onboardings" => "onboardings#welcome"

  resources :communities

  get "/notifications/scroll_refresh", to: "notifications#scroll_refresh"
  resources :notifications

  resources :comments do
    member do
      put "like", to: "comments#upvote"
      put "dislike", to: "comments#downvote"
    end
  end

  resources :onboardings, only: %i(update create) do
    collection do
      get "welcome"
      post "step2"
    end
  end

  resources :trip_locations do
    resources :accommodations
    resources :travels
    resources :events
    resources :comments

    member do
      post "send_invitation/:user_id", to: "trip_locations#send_invitation", as: :send_invitation_to
      post "accept_invitation/:user_id", to: "trip_locations#accept_invitation", as: :accept_invitation_to
      post "send_request_to_join/:user_id", to: "trip_locations#send_request_to_join", as: :send_request_to_join_to
      post "accept_request_to_join/:user_id", to: "trip_locations#accept_request_to_join", as: :accept_request_to_join_to
      delete "decline_invitation/:user_id", to: "trip_locations#decline_invitation", as: :decline_invitation_to
      delete "remove_user/:user_id", to: "trip_locations#remove_user", as: :remove_user_from
      delete "decline_request_to_join/:user_id", to: "trip_locations#decline_request_to_join", as: :decline_request_to_join_to
    end
  end

  resources :trips do
    resources :trip_locations, path: "locations"

    member do
      get "feed_post"
      put "like", to: "trips#upvote"
      put "dislike", to: "trips#downvote"
      put "maybe_for/:user_id", to: "trips#maybe_user", as: :maybe_user_for
    end
  end

  resources :locations, only: %i[create]

  get "users/:user_id/trip_locations_for_map", to: "trip_locations#trip_locations_for_map"

  resources :facts do
    member do
      put "like", to: "facts#upvote"
      put "dislike", to: "facts#downvote"
    end
  end
  # resources :landings
  resources :landings
  resources :users do
    member do
      delete "friends/:user_id", to: "users#unfriend", as: :unfriend
    end

    collection do
      get :update_location_city
      get :lookup
    end
    get "/feed", to: "feeds#index", as: :user_feed
  end

  # Bulk update of user settings on the settings screen
  put "/user_settings", to: "user_settings#update", as: "user_settings"

  get "/me/settings", to: "users#edit", as: "my_settings"

  resources :friend_requests do
    member do
      post "accept"
    end
  end

  resources :posts

  resources :activities, path: "/feed"
  get "/activities/:activity_id/comments", to: "comments#index", as: :activity_comments
  get "/activities/scroll_refresh", to: "activities#scroll_refresh"
  post "/activities/:activity_id/comments", to: "comments#create"

  post "/activities/share_form", to: "activities#share_form", as: :activity_share_form
  post "/activities/form_edit", to: "activities#edit_form", as: :activities_edit_form
  post "/activities/likes_list", to: "activities#likes_list", as: :activity_likes_list
  put "/feed", to: "activities#update", as: :activities_update
  post "/trips/show", to: "trips#privacy_settings", as: :trips_privacy_settings
end
