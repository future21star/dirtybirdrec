class BadgeKind < ApplicationRecord
  has_many :badge_points, dependent: :destroy
  has_many :badges, dependent: :destroy
end
