class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  rolify

  validates :name, presence: true

  has_many :topics
  has_many :comments
  has_many :follows
  has_many :likes

  def followed(user = nil)
    self.follows.where(target: user).first
  end
end
