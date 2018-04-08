class Release < ApplicationRecord
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
  has_many :tracks
  has_and_belongs_to_many :users

  mount_uploader :avatar, ReleaseUploader

  include AlgoliaSearch

  algoliasearch do
    attribute :title, :catalog, :upc_code, :text
  end

  scope :released, -> { where("release_date < ?", DateTime.now) }


end
