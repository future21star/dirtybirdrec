class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :target, class_name: "User"

  validates :target_id, presence: true
  validates :user, presence: true

  after_create :add_points

  include StreamRails::Activity
  as_activity

  def activity_notify
    [StreamRails.feed_manager.get_notification_feed(self.target_id)]
  end

  def activity_object
    self.target
  end

  private

    def add_points
      self.user.change_points( 100 )
    end
end
