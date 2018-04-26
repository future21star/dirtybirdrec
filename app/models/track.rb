class Track < ApplicationRecord
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
  belongs_to :release
  has_many :tracks_users, dependent: :destroy
  has_many :users, through: :tracks_users

  mount_uploader :avatar, ReleaseUploader
  mount_uploader :url, TrackUploader
  mount_uploader :sample_uri, TrackUploader

  ratyrate_rateable "main"

  include AlgoliaSearch

  algoliasearch do
    attribute :title, :genre, :isrc_code
  end

  
  def get_url
    if current_user && (current_user.subscription_type > 0 || current_user.has_role?(:paid) )
      return url
    else
      return sample_uri
    end
  end

end
