ActiveAdmin.register Release do
  config.filters = false
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
  permit_params :title, :catalog, :text, :avatar, :facebook_img,
    :published_at, :upc_code, :compilation, :release_date, 
    user_ids: [], tracks_attributes: [:id, :title, :release, :track_number,
    :genre, :isrc_code, :url, :sample_uri, :_destroy, user_ids: []]
#
# or

  form do |f|
    f.inputs do
      f.input :avatar
      f.input :title
      f.input :catalog
      f.input :text
      f.input :upc_code
      f.input :compilation
      f.input :release_date
      f.input :users
    end

    f.inputs do
      f.has_many :tracks do |t|
        t.input :title
        # t.input :track_number
        t.input :genre
        t.input :isrc_code
        t.input :url
        t.input :sample_uri
        t.input :users, :as => :select, :input_html => {:multiple => true}
      end
    end
    f.actions
  end
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

end
