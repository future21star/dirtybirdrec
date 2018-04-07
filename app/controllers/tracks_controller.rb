class TracksController < ApplicationController
  def show
    @track = Track.find(params[:id])
  end

  def get_track
    track = Track.find(params[:id])

    render json: {title: track.title, track: track.sample_uri}
  end
end
