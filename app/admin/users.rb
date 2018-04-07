ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :points, :avatar, 
      :avatar_cache, :shipping_address, :birthdate, :gender, :t_shirt_size, 
      :subscription, :subscribtion_type, track_ids: [], role_ids: []

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
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :roles, as: :check_boxes
      f.input :points
      f.input :avatar
      f.input :shipping_address
      f.input :birthdate
      f.input :gender
      f.input :t_shirt_size
      f.input :subscription
      f.input :subscribtion_type
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

      super
    end
  end

end
