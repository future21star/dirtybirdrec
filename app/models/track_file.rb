class TrackFile < ActiveRecord::Base
  belongs_to :track
  validates :track, presence: true

  has_one :release, through: :track

  enum format: [:wav, :aiff, :flac, :mp3_160, :mp3_320]
  enum encode_status: [:pending, :complete, :failed]

  def uri
    "https://#{s3_bucket}.s3.amazonaws.com/#{s3_key}"
  end

  def download_uri
    Rails.application.routes.url_helpers.track_download_path(track, format: format)
  end

  # encode_steps(audio source step, artwork step)
  def encode_steps(audio_source, artwork = false)
    throw 'audio_source required' unless audio_source

    steps = []
    options = encode_audio_options[format.to_sym]

    # Encode Audio
    audio_encode_step = TRANSLOADIT.step(
      step_name(artwork && options[:artwork]),
      '/audio/encode',
      { ffmpeg_stack: 'v2.2.3' }.merge(options)
    )
    audio_encode_step.use(audio_source)
    steps.push(audio_encode_step)

    if artwork && options[:artwork]
      # Add artwork to audio
      add_artwork_step = TRANSLOADIT.step(
        step_name,
        '/audio/artwork',
        method: 'insert',
        force_accept: true,
        use: {
          steps: [
            {
              'name' => step_name(true),
              'as' => 'audio'
            },
            {
              'name' => artwork.name,
              'as' => 'image'
            }
          ],
          'bundle_steps' => true
        }
      )
      steps.push(add_artwork_step)
    end

    steps
  end

  private

  def ffmpeg_metadata
    [
      "artist=#{track.artist}",
      "title=#{track.title}",
      "album=#{track.release.title}",
      "genre=#{track.genre}",
      "date=#{track.release.release_year}",
      "year=#{track.release.release_year}",
      "track=#{track.track_number}/#{track.release.tracks.count}",
      'comment=birdfeed.dirtybirdrecords.com'
    ]
  end

  def ffmpeg_options
    {
      write_id3v1: 1,
      write_id3v2: 1,
      id3v2_version: 3,
      metadata: ffmpeg_metadata
    }
  end

  def encode_audio_options
    {
      wav: {
        preset: 'wav'
      },
      aiff: {
        ffmpeg: ffmpeg_options.merge(f: 'aiff')
      },
      flac: {
        preset: 'flac',
        ffmpeg: ffmpeg_options
      },
      mp3_160: {
        preset: 'mp3',
        bitrate: 160_000,
        ffmpeg: ffmpeg_options,
        artwork: true
      },
      mp3_320: {
        preset: 'mp3',
        bitrate: 320_000,
        ffmpeg: ffmpeg_options,
        artwork: true
      }
    }
  end

  def step_name(art_step = false)
    art_step ? "#{self.class.name}_#{id}_before-artwork" : "#{self.class.name}_#{id}"
  end
end
