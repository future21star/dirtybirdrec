class Announcement < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :release, optional: true
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable

  after_create :feed_masterfeed

  mount_uploader :avatar, ReleaseUploader

  include StreamRails::Activity

  def followers
    User.joins(:follows).where("follows.followable_id = ? AND follows.followable_type = 'Announcement'", self.id)
  end

  # private

  def activity_object
    self
  end

    def feed_masterfeed
      feed = StreamRails.feed_manager.get_feed( 'masterfeed', 1 )
      activity_actor_id = "User:#{self.user_id}"
      activity_verb = "Announcement"
      activity_object_id = "Announcement:#{self.id}"
      activity_foreign_id = "Announcement:#{self.id}"
      activity_target_id = nil
      activity_time = created_at.iso8601
      activity = create_activity
      feed.add_activity(activity)
    end
end
