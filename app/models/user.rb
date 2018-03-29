class User < ApplicationRecord
  has_many :levels  
  has_many :badges , :through => :levels 

  def change_points(options)
    if Gioco::Core::KINDS
      points = options[:points]
      kind   = Kind.find(options[:kind])
    else
      points = options
      kind   = false
    end

    if Gioco::Core::KINDS
      raise "Missing Kind Identifier argument" if !kind
      old_pontuation = self.points.where(:kind_id => kind.id).sum(:value)
    else
      old_pontuation = self.points.to_i
    end
    new_pontuation = old_pontuation + points
    Gioco::Core.sync_resource_by_points(self, new_pontuation, kind)
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
  
  mount_uploader :avatar, AvatarUploader
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  rolify

  before_create :set_default_avatar, only: :create

  attr_accessor :subscription
  enum gender: [:female, :male]

  validates :name, presence: true

  has_many :topics
  has_many :comments
  has_many :follows
  has_many :reverse_follows,  foreign_key: "target_id",
                              class_name:  "Follow",
                              dependent:   :destroy
  has_many :followers, through: :reverse_follows, source: :user
  has_many :likes
  has_one :artist_info, foreign_key: "artist_id"
  has_many :releases
  has_many :tracks, through: :releases

  def followed(user = nil)
    self.follows.where(target: user).first
  end

  private

    def set_default_avatar
      self.remote_avatar_url = Faker::Avatar.image
    end
end
