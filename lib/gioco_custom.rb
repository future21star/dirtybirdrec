module GiocoCustom
  class Core
    def self.related_info(resource, badge, points, kind)
      old_pontuation  = resource.badge_points.where(badge_id: badge.id).sum(:value)
      related_badges  = Badge.where((old_pontuation < points) ? "points <= #{points}" : "points > #{points} AND points <= #{old_pontuation}")
      new_pontuation    = ( old_pontuation < points ) ? points - old_pontuation : - (old_pontuation - points)

      { old_pontuation: old_pontuation, related_badges: related_badges, new_pontuation: new_pontuation }
    end

    def self.sync_resource_by_points(resource, badge, points, kind = nil)

      badges         = {}
      info           = self.related_info(resource, badge, points, kind)
      old_pontuation = info[:old_pontuation]
      related_badges = info[:related_badges]
      new_pontuation = info[:new_pontuation]

      Badge.transaction do
        unless resource.badges.include?(badge)
          badge_point = BadgePoint.create({ badge_kind_id: badge.badge_kind_id, 
                badge_id: badge.try(:id), value: new_pontuation, 
                user_id: resource.id })

          if points >= badge.points
            resource.badges << badge
          end
        end
        badges
      end
    end
  end
end