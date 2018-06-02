class Download < ActiveRecord::Base
  belongs_to :track
  belongs_to :user

  enum format: [:wav, :aiff, :flac, :mp3_160, :mp3_320]

  include StreamRails::Activity
  as_activity

  def activity_object
    if self.release
      self.track.release
    else
      self.track
    end
  end

  def activity_should_sync?
    if self.user.downloads.where("release = TRUE AND created_at < ?", DateTime.now - 10.minutes).count > 0
      false
    else
      true
    end
  end
end
