class Post < ApplicationRecord
  has_many :likes, as: :likeable
  belongs_to :user
  belongs_to :topic

  belongs_to :parent,  class_name: "Post", optional: true
  has_many   :replies, class_name: "Post", foreign_key: :parent_id, dependent: :destroy

  after_create :feed_topic

  attr_accessor :post_hash

  scope :parents_posts, -> { where(parent_id: nil) }

  include AlgoliaSearch

  algoliasearch sanitize: true do
    attribute :text
  end

  include StreamRails::Activity
  as_activity

  # def activity_notify
  #   if self.commentable.try(:users)
  #     self.commentable.users.map do |user|
  #       StreamRails.feed_manager.get_notification_feed(user.id)
  #     end
  #   elsif self.commentable.try(:user)
  #     [StreamRails.feed_manager.get_notification_feed(self.commentable.user.id)]
  #   else
      
  #   end
  # end

  # def activity_object
  #   self
  # end

  def activity_object
    self
  end

  private

    def feed_topic
      return if self.parent_id.present?

      feed = StreamRails.feed_manager.get_feed( 'topic', self.topic_id )
      activity_actor_id = "User:#{self.user_id}"
      activity_verb = "Comment"
      activity_object_id = "Post:#{self.id}"
      activity_foreign_id = "Post:#{self.id}"
      activity_target_id = nil
      activity_time = created_at.iso8601
      activity = create_activity
      feed.add_activity(activity)
    end

end
