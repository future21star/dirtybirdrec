class Badge < ApplicationRecord
  has_many :badge_levels, dependent: :destroy
  has_many :users, through: :badge_levels

  has_many :badge_dependencies, dependent: :destroy
  has_many :depended_badges, through: :badge_dependencies
  accepts_nested_attributes_for :badge_dependencies
  accepts_nested_attributes_for :depended_badges
  
  has_many :reverse_badge_dependencies, foreign_key: "depended_badge_id",
                                         class_name: "BadgeDependency",
                                         dependent: :destroy
  has_many :parent_badges,through: :reverse_badge_dependencies, source: :badge

  has_many :badge_points_weights
  accepts_nested_attributes_for :badge_points_weights
  has_many :badge_action_types, through: :badge_points_weights

  belongs_to :badge_kind
  validates :name, presence: true

  mount_uploader :image, AvatarUploader


  # def add(resource_id)
  #   resource = Gioco::Core.get_resource(resource_id)

  #   if Gioco::Core::POINTS && !resource.badges.include?(self)
  #     Gioco::Core.sync_resource_by_points(resource, self.points, self.kind)
  #   elsif !resource.badges.include?(self)
  #     resource.badges << self
  #     return self
  #   end
  # end

  # def remove(resource_id)
  #   resource = Gioco::Core.get_resource(resource_id)

  #   if Gioco::Core::POINTS && resource.badges.include?(self)
  #     if Gioco::Core::KINDS
  #       kind       = self.kind
  #       badges_gap = Badge.where( "points < #{self.points} AND kind_id = #{kind.id}" ).order('points DESC')[0]
  #       Gioco::Core.sync_resource_by_points( resource, ( badges_gap.nil? ) ? 0 : badges_gap.points, kind)
  #     else
  #       badges_gap = Badge.where( "points < #{self.points}" ).order('points DESC')[0]
  #       Gioco::Core.sync_resource_by_points( resource, ( badges_gap.nil? ) ? 0 : badges_gap.points)
  #     end
  #   elsif resource.badges.include?(self)
  #     resource.levels.where( :badge_id => self.id )[0].destroy
  #     return self
  #   end
  # end
end
