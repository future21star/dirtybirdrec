class ArtistInfo < ApplicationRecord
  belongs_to :user, foreign_key: "artist_id"
  mount_uploader :avatar, AvatarUploader

  def parse_youtube
    regex = /(?:.be\/|\/watch\?v=|\/(?=p\/))([\w\/\-]+)/
    if self.video.present? && self.video.match(regex).present?
      self.video.match(regex)[1]
    end
  end
end
