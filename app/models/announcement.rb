class Announcement < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :release, optional: true
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable

  after_create :feed_masterfeed
  # after_save :change_published_date, only: :update


  mount_uploader :avatar, ReleaseUploader

  include StreamRails::Activity
  as_activity

  def followers
    User.joins(:follows).where("follows.followable_id = ? AND follows.followable_type = 'Announcement'", self.id)
  end

  def activity_notify
    [StreamRails.feed_manager.get_feed( 'general_actions', 1 )]
  end

  def activity_object
    self
  end

  def activity_notify
    [StreamRails.feed_manager.get_feed( 'general_actions', 1 )]
  end

  def activity_object
    self
  end

  #because announcements shouldn't have a user
  def activity_actor
    User.with_role(:admin).first
  end

  # def activity_time
    # published_at.iso8601
  # end

  private

    def feed_masterfeed
      feed = StreamRails.feed_manager.get_feed( 'masterfeed', 1 )
      activity = create_activity
      feed.add_activity(activity)
    end

    # def change_published_date
    #   if published_at_changed?
    #     feed = StreamRails.feed_manager.get_feed( 'general_actions', 1 )
    #     feed.remove_activity("Announcement:#{self.id}", foreign_id=true)

    #     activity = create_activity
        
    #     feed.add_activity(activity)
    #   end
    # end
end
