class Track < ApplicationRecord
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
  belongs_to :release
  has_many :tracks_users, dependent: :destroy
  has_many :users, through: :tracks_users
  has_many :track_files

  mount_uploader :avatar, ReleaseUploader
  # mount_uploader :url, TrackUploader
  # mount_uploader :sample_uri, TrackUploader

  ratyrate_rateable "main"

  include AlgoliaSearch

  algoliasearch do
    attribute :title, :genre, :isrc_code
  end

  def stream_uri(is_sample)
    return sample_uri if is_sample

    # Get most recent successfully encoded 160k mp3, or 320k mp3, or base uri
    if (track_file = track_files.where(format: TrackFile.formats[:mp3_160], encode_status: TrackFile.encode_statuses[:complete]).order(:created_at).last)
      return track_file.uri
    elsif (track_file = track_files.where(format: TrackFile.formats[:mp3_320], encode_status: TrackFile.encode_statuses[:complete]).order(:created_at).last)
      return track_file.uri
    else
      return url
    end
  end

end
