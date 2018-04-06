class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :followable, polymorphic: true
  validates :user_id, :followable_id, :followable_type, presence: true

  after_create :add_points, :feed_track
  after_destroy :unfeed_track

  include StreamRails::Activity
  as_activity

  def activity_notify
    [StreamRails.feed_manager.get_notification_feed(self.followable_id)]
  end

  def activity_object
    self.followable
  end

  private

    def add_points
      self.user.change_points( 100 )
    end

    def feed_track
      if self.followable_type == "Track"
        track_feed = StreamRails.feed_manager.get_feed( 'track', self.followable_id )
        user_feed = StreamRails.feed_manager.get_feed( 'track_user_feed', self.user_id)
        user_feed.follow(track_feed.slug, self.followable_id)

        activity = create_activity
        activity[:actor] = "Track:#{self.followable_id}"
        activity[:object] = "User:#{self.user_id}"
        track_feed.add_activity(activity)
      end
    end

    def unfeed_track
      track_feed = StreamRails.feed_manager.get_feed( 'track', self.id )
      user_feed = StreamRails.feed_manager.get_feed( 'track_user_feed', self.user_id)
      user_feed.unfollow(track_feed.slug, self.id)
    end
end
