class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_many :likes, as: :likeable
  belongs_to :parent,  class_name: "Comment", optional: true
  has_many   :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy

  after_create :add_points, :feed_commentable, :feed_masterfeed, :increment_count
  after_destroy :decrement_count, :remove_points

  validates :user_id, :body, presence: true

  attr_accessor :comment_hash

  include StreamRails::Activity
  as_activity

  def activity_notify
    if self.commentable.try(:users)
      self.commentable.users.map do |user|
        StreamRails.feed_manager.get_notification_feed(user.id)
      end
    elsif self.commentable.try(:user)
      [StreamRails.feed_manager.get_notification_feed(self.commentable.user.id)]
    else
      
    end
  end

  def activity_object
    self
  end

  def activity_target
    self.commentable
  end

  def activity_extra_data
    {'parent_id' => self.parent_id}
  end

  private

    def add_points
      self.user.change_points( 'comment', self.commentable_type )
    end

    def remove_points
      self.user.change_points( 'comment', self.commentable_type, :destroy )
    end

    def increment_count
      self_parent = parent

      while self_parent.present?
        self_parent.increment! :replies_count
        self_parent = self_parent.parent
      end
    end

    def decrement_count
      self_parent = parent

      while self_parent.present?
        self_parent.decrement! :replies_count
        self_parent = self_parent.parent
      end
    end

    def feed_commentable
      return if self.parent_id.present?

      feed = StreamRails.feed_manager.get_feed( self.commentable_type.downcase, self.commentable_id )
      activity = create_activity
      feed.add_activity(activity)
    end

    def feed_masterfeed
      feed = StreamRails.feed_manager.get_feed( 'masterfeed', 1 )
      activity = create_activity
      feed.add_activity(activity)
    end
end
