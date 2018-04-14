ActiveAdmin.register Badge do
  permit_params :name, :points, :image, :message, :badge_kind_id,
    badge_points_weights_attributes: [:id, :badge_id, :badge_action_type_id, 
    :value, :condition, :active, :_destroy], 
    badge_dependencies_attributes: [:id, :badge_id, :depended_badge_id, :_destroy]

  form do |f|
    f.inputs do
      f.input :badge_kind
      f.input :name
      f.input :image
      f.input :points
      # f.li "<label class='label'>Points</label><span>#{f.object.points || '-'}</span>".html_safe
    end
    f.inputs do
      
      BadgeActionType.all.map do |type|
        unless f.object.badge_points_weights.pluck(:badge_action_type_id).include?(type.id)
          f.object.badge_points_weights.new(badge_action_type_id: type.id)
        end
      end

      f.has_many :badge_points_weights, new_record: false, sortable: :badge_action_type do |a|
        a.input :badge_action_type, label: 'action'
        a.input :value, label: 'points'
        a.input :active

        if a.object.badge_action_type_id == BadgeActionType.find_by(name: 'role').id
          a.input :condition, label: 'role', as: :select, collection: Role.all.map {|r| [r.name, r.id]}
        elsif a.object.badge_action_type_id == BadgeActionType.find_by(name: 'member over time').id
          a.input :condition, label: 'days'
        else
          a.input :condition, label: 'No to achieve'
        end

        a.actions
      end
    end

    f.inputs do
      f.has_many :badge_dependencies do |c|
        c.input :depended_badge
        c.input :badge_id, :input_html => { :value => f.object.id }, as: :hidden
      end
    end

    f.inputs do
      f.input :message
    end

    f.actions
  end

end
