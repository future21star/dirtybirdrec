class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true
  
  after_create :add_points
  
  include StreamRails::Activity
  as_activity

  def activity_notify
    [StreamRails.feed_manager.get_notification_feed(self.likeable.id)]
  end

  def activity_object
    self.likeable
  end

  private

    def add_points
      self.user.change_points( 100 )
    end
end
