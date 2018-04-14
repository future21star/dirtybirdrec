class BadgeActionType < ApplicationRecord
  has_many :badge_dependencies
  has_many :badge_points_weights
end
