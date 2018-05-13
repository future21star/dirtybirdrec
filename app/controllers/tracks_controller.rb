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
          mp3: { url: track_presenter.stream_uri }
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

        { title: track_presenter.title, artists: artists, mp3: { url: track_presenter.stream_uri } }
      end

      current_track = { index: 0, time: 0 }
    end

      render json: { tracks: tracks, current_track: current_track }

  end

  def download
    redirect_to new_user_registration_path and return unless current_user
    redirect_to choose_profile_path and return if current_user.subscription_type.blank?

    @release = Release.find(params[:id])
    redirect_to choose_profile_path unless @release.user_allowed?(current_user)
  end
end
