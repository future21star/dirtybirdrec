class AddForumAdminToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :forum_admin, :boolean
  end
end
