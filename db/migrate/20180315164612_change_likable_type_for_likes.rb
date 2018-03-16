class ChangeLikableTypeForLikes < ActiveRecord::Migration[5.1]
  def change
    change_column :likes, :likeable_type, :string
  end
end
