class TrackUploader < CarrierWave::Uploader::Base
  storage :fog

  def store_dir
    key = Digest::MD5.hexdigest (model.inspect + mounted_as.to_s)
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}/#{key}"
  end

  # def fog_public
  #   false
  # end

  # def fog_authenticated_url_expiration
  #   1.day
  # end
end

