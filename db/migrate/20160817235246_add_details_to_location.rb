class AddDetailsToLocation < ActiveRecord::Migration
  def change
    rename_column :locations, :lat, :latitude
    rename_column :locations, :long, :longitude
    add_column :locations, :facebook_oid, :string
    add_column :locations, :name, :string
    add_reference :locations, :city, index: true
    add_reference :locations, :country, index: true
    add_reference :locations, :continent, index: true
    add_column :locations, :street, :string
    add_column :locations, :zip, :string
  end
end

# "id"=>"110941395597405",
# "name"=>"Toronto, Ontario"
# "id"=>"10155129444319972",
#   "created_time"=>"2016-08-01T10:42:53+0000",
#   "place"=>
#     "id"=>"183112268514058",
#     "location"=>
#       "city"=>"Rabat",
#       "country"=>"Morocco",
#       "latitude"=>33.991336627205,
#       "longitude"=>-6.8040188198853,
#       "street"=>"Zone Industrielle Takadoum n°15 et 16",
#       "zip"=>"10210"
#     ,
#     "name"=>"7AY Coworking"
