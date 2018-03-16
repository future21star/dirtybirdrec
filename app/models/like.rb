class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true
  
  include StreamRails::Activity
  as_activity

  # def activity_notify
  #   [StreamRails.feed_manager.get_notification_feed(self.likeable)]
  # end

  def activity_actor
    self.user
  end

  def activity_object
    self.likeable
  end
end
