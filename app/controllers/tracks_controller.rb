class TracksController < ApplicationController
  def show
    track = Track.find(params[:id])
    track_presenter = TrackPresenter.new(track, current_user)

    render json: { 
      track: { 
        id: track_presenter.id,
        title: track_presenter.title, 
        artists: track_presenter.users.map(&:name).join(' feat. '),
        mp3: track_presenter.stream_uri
      } 
    }
  end

  def get_tracks
    if current_user && current_user.playlist.present?
      tracks = []


      current_user.playlist.tracks.split(',').each do |track_id|
        track = Track.find( track_id )
        track_presenter = TrackPresenter.new(track, current_user)

        if track_presenter.users.any?
          artists = track_presenter.users.map(&:name).join(' feat. ')
        else
          artists = track_presenter.artist
        end

        tracks << {
          title: track_presenter.title,
          artists: artists,
          mp3: track_presenter.stream_uri
        }
      end

      if current_user.playlist.current_track.present?
        current_track_data = current_user.playlist.current_track.split(':')
        current_track = { index: current_track_data[0], time: current_track_data[1] }
      else
        current_track = { index: 0, time: 0 }
      end
    else
      tracks = Track.where.not('sample_uri is NULL').order(created_at: :asc).last(5).map do |track|
        track_presenter = TrackPresenter.new(track, current_user)

        if track_presenter.users.any?
          artists = track_presenter.users.map(&:name).join(' feat. ')
        else
          artists = track_presenter.artist
        end

        { title: track_presenter.title, artists: artists, mp3: track_presenter.stream_uri }
      end

      current_track = { index: 0, time: 0 }
    end

      render json: { tracks: tracks, current_track: current_track }

  end

  def download
    #TODO redirect to registration if no rights
    # redirect_to choose_profile_path and return if current_user.subscription_type.blank?
    # if current_user && current_user.admin?
    #   @track = Track.with_deleted.find(params[:id])
    # else
      @track = Track.find(params[:id])
    # end

    unless @track.user_allowed?(current_user)
      raise ActionController::RoutingError, 'Not Found'
    end

    @format = params[:format] || :mp3_320
    tf = TrackFile.find_by(track: @track, format: TrackFile.formats[@format])
    Download.create(user: current_user, track: @track, format: Download.formats[@format])

    redirect_to S3_BUCKET.object(tf.s3_key).presigned_url(:get, response_content_disposition: 'attachment')
  end
end
