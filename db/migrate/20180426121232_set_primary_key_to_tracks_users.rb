class SetPrimaryKeyToTracksUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :tracks_users, :id, :bigint
    add_column :tracks_users, :id, :primary_key
  end
end
