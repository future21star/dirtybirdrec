class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :followable, polymorphic: true
  validates :user_id, :followable_id, :followable_type, presence: true

  after_create :add_points, :feed_release
  after_destroy :unfeed_release

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

    def feed_release
      if self.followable_type == "Release"
        release_feed = StreamRails.feed_manager.get_feed( 'release', self.followable_id )
        user_feed = StreamRails.feed_manager.get_feed( 'release_user_feed', self.user_id)
        user_feed.follow(release_feed.slug, self.followable_id)

        activity = create_activity
        activity[:actor] = "Release:#{self.followable_id}"
        activity[:object] = "User:#{self.user_id}"
        release_feed.add_activity(activity)
      end
    end

    def unfeed_release
      release_feed = StreamRails.feed_manager.get_feed( 'release', self.followable_id )
      user_feed = StreamRails.feed_manager.get_feed( 'release_user_feed', self.user_id)
      user_feed.unfollow(release_feed.slug, self.user_id)
    end
end
