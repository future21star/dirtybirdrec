ActiveAdmin.register Track do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
  permit_params :title, :release_id, :track_number, :genre, :isrc_code,
      :url, :sample_uri, :waveform_image_uri, user_ids: []
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  form do |f|
    f.inputs do
      f.input :avatar
      f.input :title
      f.input :release
      f.input :track_number
      f.input :genre
      f.input :isrc_code
      f.input :url
      f.input :sample_uri
      f.input :waveform_image_uri
      f.input :users, :as => :select, :input_html => {:multiple => true}
    end
    f.actions
  end

end
