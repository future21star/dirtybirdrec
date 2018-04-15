class User < ApplicationRecord
  include HomeHelper
  mount_uploader :avatar, AvatarUploader
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook, :google_oauth2]
  rolify

  before_create :set_default_avatar, only: :create
  after_create :set_fan_role, only: :create

  attr_accessor :subscription
  enum gender: [:female, :male]

  validates :name, presence: true

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
  has_many :tracks_users
  has_many :tracks, through: :tracks_users

  include AlgoliaSearch
  include GiocoCustom

  algoliasearch do
    attribute :name
  end

  def vip?
    # Admins are also VIPs
    subscription_type == 'vip' || subscription_type == 'admin'
  end

  def admin?
    subscription_type == 'admin'
  end

  def followers
    User.joins(:follows).where("follows.followable_id = ? AND follows.followable_type = 'User'", self.id)
  end

  def already_liked object
    likes.where("likeable_id = ? AND likeable_type = ?", object.id, object.class.to_s).first
  end


  def change_points(action_type, method=false)
    raise "Missing Kind Identifier argument" if !action_type

    weights = "SELECT badge_id FROM badge_points_weights INNER JOIN badge_action_types ON badge_action_types.id = badge_points_weights.badge_action_type_id WHERE badge_action_types.name = :action_type"
    badges = Badge.where("id IN (#{weights})", action_type: action_type)

    badges.each do |badge|

      related_badges_should_be = badge.depended_badges.pluck(:id)
      user_badges = self.badges.pluck(:id)

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

      role = BadgePointsWeight.joins(:badge_action_type).where('badge_action_types.name = ? AND badge_id = ?',  'role', badge.id).first

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
      GiocoCustom::Core.sync_resource_by_points(self, badge, new_pontuation)
    end
  end

  def next_badge?(kind_id = false)
    if Gioco::Core::KINDS
      raise "Missing Kind Identifier argument" if !kind_id
      old_pontuation = self.points.where(:kind_id => kind_id).sum(:value)
    else
      old_pontuation = self.points.to_i
    end
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
