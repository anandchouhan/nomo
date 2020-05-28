class AddCitySignatureToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :city_signature, :string
    
    Location.all.each do |location|
      if location.city_signature.blank?
        location.set_city_signature
        location.save
      end
    end
  end
end
