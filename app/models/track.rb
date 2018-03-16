class Track < ApplicationRecord
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
  belongs_to :release
end
