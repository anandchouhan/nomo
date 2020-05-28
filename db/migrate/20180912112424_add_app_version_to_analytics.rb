class AddAppVersionToAnalytics < ActiveRecord::Migration[5.2]
  def change
    add_column :analytics, :app_version, :float
    add_column :analytics, :email, :string
    add_column :analytics, :metric_classification, :string
    add_column :analytics, :metric_identifier, :string
  end
end
