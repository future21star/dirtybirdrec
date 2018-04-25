class TracksController < ApplicationController
  def show
    @track = Track.find(params[:id])
  end

  def get_tracks
    # if cuttent_user && current_user.playlist.present?
    #   tracks = []

    #   current_user.playlist.tracks.split(',').each do |track_id|
    #     track = Track.find( track_id )
    #     artists = track.users.pluck(:name).join(' feat. ')

    #     tracks << {
    #       title: track.title,
    #       artists: artists,
    #       mp3: track.get_url # TODO check for subscription
    #     }
    #   end

    #   if current_user.playlist.current_track.present?
    #     current_track_data = current_user.playlist.current_track.split(':')
    #     current_track = { index: current_track_data[0], time: current_track_data[1] }
    #   else
    #     current_track = { index: 0, time: 0 }
    #   end
    # else
      # tracks = Track.last(5).map do |track|
      #   artists = track.users.pluck(:name).join(' feat. ')
      #   { title: track.title, artists: artists, mp3: track.get_url } # TODO check for subscription
      # end

      tracks = [
        {
          title:"Tempered Song",
          artists: "Artist 1 feat. Artist 2",
          mp3:"http://www.jplayer.org/audio/mp3/Miaow-01-Tempered-song.mp3",
          oga:"http://www.jplayer.org/audio/ogg/Miaow-01-Tempered-song.ogg"
        },
        {
          title:"Hidden",
          artists: "Artist 3 feat. Artist 4",
          mp3:"http://www.jplayer.org/audio/mp3/Miaow-02-Hidden.mp3",
          oga:"http://www.jplayer.org/audio/ogg/Miaow-02-Hidden.ogg"
        },
        {
          title:"Lentement",
          artists: "Artist 5 feat. Artist 6",
          mp3:"http://www.jplayer.org/audio/mp3/Miaow-03-Lentement.mp3",
          oga:"http://www.jplayer.org/audio/ogg/Miaow-03-Lentement.ogg"
        },
        {
          artists: "Artist 7 feat. Artist 8",
          title:"Lismore",
          mp3:"http://www.jplayer.org/audio/mp3/Miaow-04-Lismore.mp3",
          oga:"http://www.jplayer.org/audio/ogg/Miaow-04-Lismore.ogg"
        },
        {
          artists: "Artist 9 feat. Artist 10",
          title:"The Separation",
          mp3:"http://www.jplayer.org/audio/mp3/Miaow-05-The-separation.mp3",
          oga:"http://www.jplayer.org/audio/ogg/Miaow-05-The-separation.ogg"
        }
      ]
      current_track = { index: 2, time: 10 }
    # end

      render json: { tracks: tracks, current_track: current_track }

  end

  def download
    redirect_to new_user_registration_path and return unless current_user
    redirect_to choose_profile_path and return if current_user.subscription_type.blank?

    @release = Release.find(params[:id])
    redirect_to choose_profile_path unless @release.user_allowed?(current_user)
  end
end
