class CreateUsersTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :tracks_users, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :track, index: true
    end
  end
end
