class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_many :likes, as: :likeable

  include StreamRails::Activity
  as_activity

  # def activity_notify
  #   [StreamRails.feed_manager.get_notification_feed(self.target_id)]
  # end

  def activity_actor
    self.user
  end

  def activity_object
    self.commentable
  end
end
