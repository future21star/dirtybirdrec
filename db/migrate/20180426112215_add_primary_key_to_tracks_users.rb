class AddPrimaryKeyToTracksUsers < ActiveRecord::Migration[5.1]
  def change
    self.primary_key = "id"
  end
end
