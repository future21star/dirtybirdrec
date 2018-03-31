class TopicCategory < ApplicationRecord
  has_many :topics, foreign_key: 'category_id'
  belongs_to :group, foreign_key: 'group_id', 
             class_name: "TopicCategoryGroup", optional: true

  validates :group_id, presence: true

end
