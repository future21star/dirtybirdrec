class AddPrimaryKeyToTracksUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :tracks_users, :id, :primary_key
  end
end
