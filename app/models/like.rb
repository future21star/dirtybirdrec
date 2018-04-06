class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true
  
  after_create :add_points, :feed_track
  
  include StreamRails::Activity
  as_activity

  def activity_notify
    [StreamRails.feed_manager.get_notification_feed(self.likeable.id)]
  end

  def activity_object
    self.likeable
  end

  private

    def add_points
      self.user.change_points( 100 )
    end

    def feed_track
      if self.likeable_type == "Comment"
        comment = self.likeable
        track_feed = StreamRails.feed_manager.get_feed( 'track', comment.commentable_id )
        activity = create_activity
        activity[:actor] = "Track:#{self.likeable_id}"
        activity[:object] = "User:#{self.user_id}"
        track_feed.add_activity(activity)
      end
    end
end
