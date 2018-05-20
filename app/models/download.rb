class Download < ActiveRecord::Base
  belongs_to :track
  belongs_to :user

  enum format: [:wav, :aiff, :flac, :mp3_160, :mp3_320]
end
