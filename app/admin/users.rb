ActiveAdmin.register User do
  before_action do
    @user = User.find_by_username(params[:id])
  end

  permit_params :username,
                :name,
                :email,
                :hometown_id,
                :location_id,
                :phone_number,
                :website,
                :bio,
                :quote,
                :date_of_birth,
                :twitter_id,
                :facebook_id,
                :instagram_id,
                :linked_in_id,
                :youtube_id,
                :blog_id,
                :exclude_analytics

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :username
      f.input :name
      f.input :email
      f.input :hometown_id, as: :select, collection: Location.all.map { |location| [location.city_signature_or_formatted_address, location.id] }
      f.input :location_id, as: :select, collection: Location.all.map { |location| [location.city_signature_or_formatted_address, location.id] }
      f.input :phone_number
      f.input :website
      f.input :bio
      f.input :quote
      f.input :date_of_birth, as: :date_time_picker, picker_options: { timepicker: false }
      f.input :twitter_id
      f.input :facebook_id
      f.input :instagram_id
      f.input :linked_in_id
      f.input :youtube_id
      f.input :blog_id
      f.input :exclude_analytics
    end

    panel "Trips Participating" do
      table_for user.trips_participating do
        column "ID", :id
        column "Name", :name
        column "Description", :description
      end
    end

    f.actions
  end
end
