class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :followable, polymorphic: true
  validates :user_id, :followable_id, :followable_type, presence: true

  after_create :add_points, :feed_release
  after_save :trigger_followers_count
  before_destroy :trigger_followers_count
  after_destroy :unfeed_release#, :remove_points

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
      self.user.change_points( 'follow' )
    end

    # def remove_points
    #   self.user.change_points( 'follow', :delete )
    # end

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

    def trigger_followers_count
      if self.user.has_role?(:artist)
        artist_info = ArtistInfo.find_or_create_by(artist_id: self.user.id)
        artist_info.update_attributes(followers_count: self.user.followers.count - 1)
      end
    end
end
