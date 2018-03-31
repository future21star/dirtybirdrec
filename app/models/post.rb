class Post < ApplicationRecord
  has_many :likes, as: :likeable
  belongs_to :user
  belongs_to :topic

  belongs_to :parent,  class_name: "Post", optional: true
  has_many   :replies, class_name: "Post", foreign_key: :parent_id, dependent: :destroy

  attr_accessor :post_hash

  scope :parents_posts, -> { where(parent_id: nil) }

end
