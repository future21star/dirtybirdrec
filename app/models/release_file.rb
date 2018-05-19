class ReleaseFile < ActiveRecord::Base
  belongs_to :release
  # validates :release, presence: true

  enum format: [:wav, :aiff, :flac, :mp3_160, :mp3_320]
  enum encode_status: [:pending, :complete, :failed]

  belongs_to :group, -> { with_deleted }

  def uri
    "https://#{s3_bucket}.s3.amazonaws.com/#{s3_key}"
  end

  def download_uri
    Rails.application.routes.url_helpers.release_download_path(release, format: format)
  end

  def encode_steps(file_steps)
    throw 'file_steps required' unless file_steps

    # Encode ZIP
    [
      TRANSLOADIT.step(
        step_name,
        '/file/compress',
        format: 'zip',
        file_layout: 'simple',
        use: {
          steps: file_steps.map(&:name),
          bundle_steps: true
        }
      )
    ]
  end

  private

  def step_name
    "#{self.class.name}_#{id}"
  end
end
