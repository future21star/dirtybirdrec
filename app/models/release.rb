class Release < ApplicationRecord
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
  has_many :tracks
  has_many :announcements
  
  has_and_belongs_to_many :users

  after_create :feed_masterfeed

  accepts_nested_attributes_for :tracks

  mount_uploader :avatar, ReleaseUploader

  ratyrate_rateable "main"

  include AlgoliaSearch

  include StreamRails::Activity
  as_activity

  algoliasearch sanitize: true do
    attribute :title, :catalog, :upc_code, :text
    # tags [self.published? ? 'published' : 'unpublished']
  end

  scope :released, -> { where("release_date < ?", DateTime.now).order(release_date: :desc) }

  def user_allowed?(user)
    return false unless user
    return true if user.vip?
    return false unless published?
    return false unless user.subscription_started_at
    return true if available_to_all?
    return true if published_at >= user.subscription_started_at - 3.months
    false
  end

  def published?
    !published_at.nil? && published_at <= DateTime.now
  end

  def activity_object
    self
  end

  def activity_actor
    User.with_role(:admin).first
  end

  def verb
    "Announcement"
  end

  private

    def feed_masterfeed
      feed = StreamRails.feed_manager.get_feed( 'masterfeed', 1 )
      activity = create_activity
      feed.add_activity(activity)
    end
end
