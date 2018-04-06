class Track < ApplicationRecord
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
  belongs_to :release
  has_and_belongs_to_many :users

  mount_uploader :avatar, ReleaseUploader

  include AlgoliaSearch

  algoliasearch do
    attribute :title, :genre, :isrc_code
  end
end
