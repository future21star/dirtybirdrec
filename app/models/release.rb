class Release < ApplicationRecord
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
  has_many :tracks
end
