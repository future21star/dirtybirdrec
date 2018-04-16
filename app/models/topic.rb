class Topic < ApplicationRecord
  belongs_to :user
  belongs_to :category, foreign_key: 'category_id', 
             class_name: "TopicCategory", optional: true
  has_many :likes, as: :likeable
  has_many :posts

  validates :user_id, :category_id, presence: true

  include AlgoliaSearch

  algoliasearch sanitize: true do
    attribute :title, :text
  end

end
