class SetPrimaryKeyToTracksUsers < ActiveRecord::Migration[5.1]
  def change
    execute "ALTER TABLE tracks_users ADD PRIMARY KEY (id);"
  end
end
