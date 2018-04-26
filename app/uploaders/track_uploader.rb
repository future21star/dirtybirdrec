class TrackUploader < CarrierWave::Uploader::Base
  storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # def fog_public
  #   false
  # end

  # def fog_authenticated_url_expiration
  #   1.day
  # end
end
