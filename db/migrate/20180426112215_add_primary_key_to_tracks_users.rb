class AddPrimaryKeyToTracksUsers < ActiveRecord::Migration[5.1]
  def change
    # add_column :tracks_users, :id, :bigint
    execute "ALTER TABLE tracks_users ADD PRIMARY KEY (id);"
  end
end
