class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_many :likes, as: :likeable

  after_create :add_points

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
end
