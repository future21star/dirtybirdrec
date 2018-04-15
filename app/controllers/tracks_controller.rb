class TracksController < ApplicationController
  def show
    @track = Track.find(params[:id])
  end

  def get_track
    track = Track.find(params[:id])

    render json: {title: track.title, track: track.sample_uri}
  end

  def download
    redirect_to new_user_registration_path and return unless current_user
    redirect_to choose_profile_path and return if current_user.subscription_type.blank?

    @release = Release.find(params[:id])
    redirect_to choose_profile_path unless @release.user_allowed?(current_user)
  end
end
