class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :followable, polymorphic: true
  validates :user_id, :followable_id, :followable_type, presence: true

  after_create :add_points, :feed_masterfeed#, :feed_release_topic_announcement
  after_save :trigger_followers_count
  before_destroy :trigger_followers_count#, :unfeed_release_topic_announcement#, :remove_points

  include StreamRails::Activity
  as_activity

  def activity_notify
    if self.followable_type == 'User'
      [StreamRails.feed_manager.get_notification_feed(self.followable_id)]
    end
  end

  def activity_object
    self.followable
  end

  private

    def add_points
      # self.user.change_points( 'follow' )
    end

    # def remove_points
    #   self.user.change_points( 'follow', :delete )
    # end

    # def feed_release_topic_announcement

    # end

    # def unfeed_release_topic_announcement

    # end

    def feed_masterfeed
      feed = StreamRails.feed_manager.get_feed( 'masterfeed', 1 )
      activity = create_activity
      feed.add_activity(activity)
    end

    def trigger_followers_count
      if self.user.has_role?(:artist)
        artist_info = ArtistInfo.find_or_create_by(artist_id: self.user.id)
        artist_info.update_attributes(followers_count: self.user.followers.count - 1)
      end
    end
end
