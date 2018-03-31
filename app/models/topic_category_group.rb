class TopicCategoryGroup < ApplicationRecord
  has_many :categories, foreign_key: 'group_id', class_name: 'TopicCategory'

end
