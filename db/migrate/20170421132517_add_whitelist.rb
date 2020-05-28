class AddWhitelist < ActiveRecord::Migration
  def change
    create_table :whitelists
    add_column :whitelists, :event, :string
    add_column :whitelists, :uuid, :string
    add_column :whitelists, :email, :string
    add_column :whitelists, :name, :string
    add_column :whitelists, :safe_name, :string
    add_column :whitelists, :position, :integer
    add_column :whitelists, :affiliate, :string
    add_column :whitelists, :activated_at, :date
    add_column :whitelists, :activation_code, :string
    add_column :whitelists, :referred_count, :string
    add_column :whitelists, :responses, :string
    add_column :whitelists, :created_at, :date
    add_column :whitelists, :referred_by, :string
  end
end
