class Release < ApplicationRecord
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
  has_many :tracks
  has_and_belongs_to_many :users

  mount_uploader :avatar, ReleaseUploader

  include AlgoliaSearch

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
end
