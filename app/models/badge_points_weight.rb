class BadgePointsWeight < ApplicationRecord
  belongs_to :badge
  belongs_to :badge_action_type
end
