class Announcement < ApplicationRecord
  belongs_to :user
  belongs_to :release
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable

  mount_uploader :avatar, ReleaseUploader

  def followers
    User.joins(:follows).where("follows.followable_id = ? AND follows.followable_type = 'Announcement'", self.id)
  end
end
