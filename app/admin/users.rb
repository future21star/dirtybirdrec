ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :avatar, 
      :avatar_cache, :shipping_address, :birthdate, :gender, :t_shirt_size, 
      :subscription_type, :first_name, :last_name, :city, #:subscription,
      track_ids: [], role_ids: [], release_ids: []

  jcropable

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :avatar, hint: image_tag(f.object.avatar.url(:thumb)), as: :jcropable
      f.input :avatar_cache, as: :hidden
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :roles, as: :check_boxes
      f.input :city
      f.input :shipping_address
      f.input :birthdate, as: :date_time_picker
      f.input :gender
      f.input :t_shirt_size
      # f.input :subscription
      f.input :subscription_type
      f.input :releases
      f.input :tracks
    end
    f.actions
  end

  controller do
    def update
      if params[:user][:password].blank?
        params[:user].delete "password"
        params[:user].delete "password_confirmation"
      end

      if params[:user][:avatar].present?


      end
      super
    end
  end

end
