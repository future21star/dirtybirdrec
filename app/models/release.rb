class Release < ApplicationRecord
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
  has_many :tracks
  belongs_to :user, foreign_key: "artist_id"

  mount_uploader :image_url, AvatarUploader

  include AlgoliaSearch

  algoliasearch do
    attribute :title, :catalog, :upc_code, :text
  end

end
