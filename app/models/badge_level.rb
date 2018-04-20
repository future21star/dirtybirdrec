class BadgeLevel < ApplicationRecord
  belongs_to :badge, inverse_of: :badge_levels
  belongs_to :user, inverse_of: :badge_levels
end
