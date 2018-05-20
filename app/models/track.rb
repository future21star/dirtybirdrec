class Track < ApplicationRecord
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
  belongs_to :release
  has_many :tracks_users, dependent: :destroy
  has_many :users, through: :tracks_users
  has_many :track_files
  has_many :downloads

  mount_uploader :uri, TrackUploader

  validates :track_number, presence: true

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
      return uri.url
    end
  end

  def download_uris
    uris = track_files.empty? ? { 'WAV' => uri.url } : {}
    %w[mp3_320 aiff flac wav].each do |format|
      tf = track_files.find_by(format: TrackFile.formats[format])
      uris[format.split('_').first.upcase,] = tf.download_uri if tf
    end

    uris
  end

  def file_name
    "#{'%02i' % track_number}. #{artist} - #{title} - Dirtybird".gsub(/[^0-9A-Za-z.\(\)\-\  ]/, '')
  end

  def sample_file_name
    "#{'%02i' % track_number}. #{artist} - #{title} - Sample - Dirtybird".gsub(/[^0-9A-Za-z.\(\)\-\  ]/, '')
  end

  def audio_import_step
    # TODO: see if we can go back to /s3/import by renaming files somewhere in the pipeline
    TRANSLOADIT.step(
      "#{step_name}_import",
      '/http/import',
      url: uri.url.split(/\?/).first, # TODO: remove hack for old drip tracks my moving them to secure place
      # periods stop the name for continuing, so remove them and add one at the end
      force_name: "#{file_name.delete('.').tr(' ', '_')}."
    )
  end

  def sample_encode_steps(import = false)
    steps = []
    steps.push(audio_import_step) if import

    # extend songs that aren't long enough for sample
    extend_song_step = TRANSLOADIT.step(
      "#{step_name}_sample_audio_extend",
      '/audio/loop',
      duration: 210,
      result: true,
      preset: 'mp3',
      use: "#{step_name}_import"
    )

    sample_audio_encode_step = TRANSLOADIT.step(
      "#{step_name}_sample_audio_encode",
      '/audio/encode',
      preset: 'mp3',
      bitrate: 160_000,
      artwork: true,
      ffmpeg_stack: 'v2.2.3',
      ffmpeg: {
        ss: '180',
        t: '30'
      }
    )

    sample_audio_export_step = TRANSLOADIT.step(
      "#{step_name}_sample_export",
      '/s3/store',
      key: ENV['AWS_ACCESS_KEY_ID'],
      secret: ENV['AWS_SECRET_ACCESS_KEY'],
      bucket: ENV['S3_BUCKET_UPLOADS'],
      path: "tracks/${unique_prefix}/#{sample_file_name}.${file.ext}"
    )

    steps.push(extend_song_step)
    steps.push(sample_audio_encode_step)
    steps.push(sample_audio_export_step)
    steps
  end

  def waveform_encode_steps(import = false)
    steps = []
    steps.push(audio_import_step) if import

    # Generate Waveform
    steps.push(
      TRANSLOADIT.step(
        "#{step_name}_waveform",
        '/audio/waveform',
        format: 'json',
        use: "#{step_name}_import"
      )
    )

    # Export Waveform
    steps.push(
      TRANSLOADIT.step(
        "#{step_name}_waveform_export",
        '/s3/store',
        key: ENV['AWS_ACCESS_KEY_ID'],
        secret: ENV['AWS_SECRET_ACCESS_KEY'],
        bucket: ENV['S3_BUCKET_UPLOADS'],
        path: "waveforms/${unique_prefix}/#{file_name}.${file.ext}",
        use: "#{step_name}_waveform"
      )
    )

    steps
  end

  def encode_steps(formats = [:mp3_320], artwork = nil)
    steps = []
    steps.push(audio_import_step)
    steps.concat(sample_encode_steps)
    steps.concat(waveform_encode_steps)

    # Track what steps we should export to S3
    track_export_steps = []

    formats.each do |format|
      # Create TrackFile first, in case of race condition with callback
      track_file = TrackFile.create(
        track: self,
        format: format,
        encode_status: :pending
      )
      track_file_steps = track_file.encode_steps(audio_import_step, nil)
      steps.concat track_file_steps
      track_export_steps.push track_file_steps.last
    end

    # Set up export step
    # TODO: disable the aa/aaifjdsoi-cjsidofs aa prefix on unique_prefix, use real folder structure
    audio_export_step = TRANSLOADIT.step(
      "#{step_name}_export",
      '/s3/store',
      key: ENV['AWS_ACCESS_KEY_ID'],
      secret: ENV['AWS_SECRET_ACCESS_KEY'],
      bucket: ENV['S3_BUCKET_UPLOADS'],
      path: "tracks/${unique_prefix}/#{file_name}.${file.ext}"
    )
    

    audio_export_step.use(track_export_steps)
    steps.push(audio_export_step)

    steps
  end

  def audio_import_step
    # TODO: see if we can go back to /s3/import by renaming files somewhere in the pipeline
    TRANSLOADIT.step(
      "#{step_name}_import",
      '/http/import',
      url: uri.url.split(/\?/).first, # TODO: remove hack for old drip tracks my moving them to secure place
      # periods stop the name for continuing, so remove them and add one at the end
      force_name: "#{file_name.delete('.').tr(' ', '_')}."
    )
  end

  def user_allowed?(user)
    return false unless user
    return true if user.vip?
    return false unless release.published?
    return false unless user.subscription_started_at
    return true if release.available_to_all?
    return true if release.published_at >= user.subscription_started_at - 3.months
    false
  end

  private

    def step_name
      "#{self.class.name}_#{id}"
    end

end
