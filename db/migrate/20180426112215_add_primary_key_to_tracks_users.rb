class AddPrimaryKeyToTracksUsers < ActiveRecord::Migration[5.1]
  def change
    execute "ALTER TABLE tracks_uasers ADD PRIMARY KEY (id);"
  end
end
