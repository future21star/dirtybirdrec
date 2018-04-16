class TopicCategoryGroup < ApplicationRecord
  mount_uploader :image, DefaultUploader
  
  has_many :categories, foreign_key: 'group_id', class_name: 'TopicCategory'
end
