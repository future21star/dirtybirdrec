class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_many :likes, as: :likeable

  after_create :add_points, :feed_track

  include StreamRails::Activity
  as_activity

  def activity_notify
    [StreamRails.feed_manager.get_notification_feed(self.commentable.id)]
  end

  def activity_object
    self.commentable
  end

  private

    def add_points
      self.user.change_points( 100 )
    end

    def feed_track
      if self.commentable_type == "Track"
        track_feed = StreamRails.feed_manager.get_feed( 'track', self.commentable_id )
        activity = create_activity
        activity[:actor] = "Track:#{self.commentable_id}"
        activity[:object] = "User:#{self.user_id}"
        track_feed.add_activity(activity)
      end
    end
end
