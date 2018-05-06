class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true
  
  after_create :add_points, :trigger_likes_count
  after_destroy :trigger_likes_count#, :remove_points

  
  include StreamRails::Activity
  as_activity

  def activity_notify
    if self.likeable.try(:users)
      self.likeable.users.map do |user|
        StreamRails.feed_manager.get_notification_feed(user.id)
      end
    else
      [StreamRails.feed_manager.get_notification_feed(self.likeable.user.id)]
    end
  end

  def activity_object
    self.likeable
  end

  private

    def add_points
      self.user.change_points( 'like' )
    end

    # def remove_points
    #   self.user.change_points( 'like', :destroy )
    # end


    def trigger_likes_count
      case self.likeable_type
      when "Comment" || "Video"
        self.likeable.update_attributes(likes_count: self.likeable.likes.count)
      end
    end
end
