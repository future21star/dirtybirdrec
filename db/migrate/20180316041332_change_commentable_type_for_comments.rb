class ChangeCommentableTypeForComments < ActiveRecord::Migration[5.1]
  def change
    change_column :comments, :commentable_type, :string

  end
end
