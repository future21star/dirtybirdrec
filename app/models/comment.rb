class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_many :likes, as: :likeable

  after_create :add_points, :feed_release

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

    def feed_release
      if self.commentable_type == "Release"
        feed = StreamRails.feed_manager.get_feed( 'release', self.commentable_id )
        activity = create_activity
        activity[:actor] = "Release:#{self.commentable_id}"
        activity[:object] = "User:#{self.user_id}"
        feed.add_activity(activity)
      end
    end
end
