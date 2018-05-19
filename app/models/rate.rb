class Rate < ActiveRecord::Base
  belongs_to :rater, :class_name => "User"
  belongs_to :rateable, :polymorphic => true

  #attr_accessible :rate, :dimension

  after_create :add_points
  after_destroy :remove_points

  private 

    def add_points
      self.user.change_points( 'rate', self.rateable_type )
    end

    def remove_points
      self.user.change_points( 'rate', self.rateable_type, :destroy )
    end

end