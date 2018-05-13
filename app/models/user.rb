class User < ApplicationRecord
  include HomeHelper
  mount_uploader :avatar, AvatarUploader
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook, :google_oauth2]
  rolify
  ratyrate_rater

  before_create :set_default_avatar, only: :create
  after_create :set_fan_role, only: :create

  attr_accessor :subscription
  enum gender: [:female, :male]

  validates :first_name, presence: true

  enum subscription_type: [:member, :vip, :admin]

  has_many :badge_levels
  has_many :badges, through: :badge_levels
  has_many :badge_points

  has_many :topics
  has_many :posts
  has_many :comments
  has_many :commented, as: :commentable, class_name: 'Comment'
  has_many :videos

  has_many :follows
  has_many :followed_users, through: :follows, source: :followable, source_type: "User"

  has_many :likes
  has_one :artist_info, foreign_key: "artist_id"
  has_and_belongs_to_many :releases
  has_many :announcements
  has_many :tracks_users
  has_many :tracks, through: :tracks_users

  include AlgoliaSearch
  include BadgeSystem

  algoliasearch do
    attribute :first_name, :last_name
  end

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :crop_avatar

  def crop_avatar
    avatar.recreate_versions! if crop_x.present?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def online?
    begin
      $redis_onlines.exists( self.id )
    rescue Redis::CannotConnectError
      return false
    end
  end

  def vip?
    # Admins are also VIPs
    subscription_type == 'vip' || subscription_type == 'admin'
  end

  def admin?
    subscription_type == 'admin'
  end

  def active_subscription?
    return true if subscription_type == 'vip' || subscription_type == 'admin'

    return false unless subscription_started_at

    if braintree_subscription
      if braintree_subscription_expires_at && Date.today <= braintree_subscription_expires_at
        return true
      end
    end

    false
  end

  def followers
    User.joins(:follows).where("follows.followable_id = ? AND follows.followable_type = 'User'", self.id)
  end

  def posts_from_followed_topics
    topic_ids = "SELECT followable_id FROM follows WHERE user_id = :user_id AND followable_type = 'Topic'"
    Post.where("topic_id IN (#{topic_ids})", user_id: self.id).order(created_at: :desc)
  end

  def already_liked object
    likes.where("likeable_id = ? AND likeable_type = ?", object.id, object.class.to_s).first
  end


  def change_points(action_type, action_kind)
    raise "Missing Kind Identifier argument" if !action_type || !action_kind

    music = BadgeKind.find_by_name('music')
    forum = BadgeKind.find_by_name('forum')
    community = BadgeKind.find_by_name('community')

    action_kind_id = case action_kind
    when "Release" then music
    when "Track" then music
    when "Topic" then forum
    when "Post" then forum
    when "User" then community
    end

    weights = "SELECT badge_id FROM badge_points_weights INNER JOIN badge_action_types ON badge_action_types.id = badge_points_weights.badge_action_type_id WHERE badge_action_types.name = :action_type AND badge_action_types.badge_kind_id = :action_kind_id"
    badges = Badge.where("id IN (#{weights})", action_type: action_type, action_kind_id: action_kind_id)

    user_badges = self.badges.pluck(:id)

    badges.reject { |b| user_badges.inclueds?(b.id) if user_badges.present? }.each do |badge|

      related_badges_should_be = badge.depended_badges.pluck(:id)

      if related_badges_should_be.present?
        if related_badges_should_be.all? { |i| user_badges.include?(i) }
          last_related_badge = "(SELECT MAX(created_at) FROM badge_levels WHERE user_id = :user_id AND badge_id IN (:badge_id))"
          related_badges_user_have = related_badges_should_be & user_badges
        else
          next
        end
      else
        last_related_badge = "(SELECT created_at FROM users WHERE id = :user_id)"
      end

      weight = BadgePointsWeight.joins(:badge_action_type)
          .where('badge_action_types.name = ? AND badge_id = ?', 
              action_type, badge.id).first
      next unless weight.active?

      role = BadgePointsWeight.joins(:badge_action_type).where('badge_action_types.name = ? AND badge_id = ?', 'role', badge.id).first

      if role.present? && role.active?
        next unless self.has_role? role.value
      end

      case action_type
      when 'like'
        match = self.likes
          .where("created_at > #{last_related_badge}", user_id: self.id, badge_id: related_badges_user_have)
          .count == weight.condition.to_i

      when 'follow' 
        match = self.follows
          .where("created_at > #{last_related_badge}", user_id: self.id, badge_id: related_badges_user_have)
          .count == weight.condition.to_i

      when 'member over time' then match = (Date.current - self.created_at.to_date).to_i >= weight.condition.to_i
      else next end

      if match
        points = weight.value.to_i
      else 
        next 
      end

      old_pontuation = self.badge_points.where(badge_id: badge.id).sum(:value)
      new_pontuation = old_pontuation + points
      BadgeSystem::Core.sync_resource_by_points(self, badge, new_pontuation)
    end
  end

  def next_badge?(kind_id = false)
    raise "Missing Kind Identifier argument" if !kind_id
    old_pontuation = self.points.where(:kind_id => kind_id).sum(:value)

    next_badge       = Badge.where("points > #{old_pontuation}").order("points ASC").first
    last_badge_point = self.badges.last.try('points')
    last_badge_point ||= 0

    if next_badge
      percentage      = (old_pontuation - last_badge_point)*100/(next_badge.points - last_badge_point)
      points          = next_badge.points - old_pontuation
      next_badge_info = {
                          :badge      => next_badge,
                          :points     => points,
                          :percentage => percentage
                        }
    end
  end

  def followed(object = nil)
    self.follows.where(followable_id: object.id, followable_type: object.class.to_s).first
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      if auth.info.email
        user.email = auth.info.email
        user.name = auth.info.email.split('@')[0]
      else
        user.email = "example@mail.com"
        user.name = "noname"
      end
      user.password = Devise.friendly_token[0,20]
      #user.social_profile_picture = auth.info.image # assuming the user model has an image
    end
  end

  def points kind_id=nil
    if kind_id
      badge_points.where(badge_kind_id: kind_id).sum(:value)
    else
      badge_points.sum(:value)
    end
  end

  private

    def set_default_avatar
      self.avatar = primary_avatar(self.name)
    end

    def set_fan_role
      self.add_role :fan
    end
end
