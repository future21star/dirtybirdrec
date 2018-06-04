class ReleasesController < ApplicationController
  include ReleasesHelper
  before_action :set_notifications, only: [:show, :index]

  def show
    release = Release.find(params[:id])
    @release = ReleasePresenter.new(release, current_user)

    begin
      feed = StreamRails.feed_manager.get_feed('release', @release.id)
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed
      results = []
    end

    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results)
  end

  def index
    filters = params[:filters]
    page = params[:page] || 1

    @releases = Release.released

    @releases = set_filters filters

    @releases = releases_query( @releases, page, 16, true )

    @artists = User.with_role(:artist)
  end

  def set_filters filters
    if filters.present?
      filters.each do |filter, value|
        case filter
        when 'never_released' 
          @releases = @releases.where("release_date > ? OR release_date = NULL", Date.today)
        when 'three_months' 
          @releases = @releases.where("release_date > ? AND release_date < ?", Date.today - 3.months, Date.today)
        when 'year'
          @releases = @releases.where("extract(year from release_date) = ?", value)
        when 'artist'
          @releases = @releases.joins(:releases_users).where("releases_users.user_id = ?", value)
        when 'not_downloaded' 
          @releases = @releases.where("release_date > ? OR release_date = NULL")
        end
      end
    end

    @releases
  end

  def load_more
    @releases = Release.released
    @releases = set_filters params[:filters]
    @releases = releases_query( @releases, params[:page], 16, false )
  end

  def download
    #TODO send to registration if no rights
    # redirect_to choose_profile_path and return if current_user.subscription_type.blank?
    # if current_user && current_user.admin?
    #   @release = Release.with_deleted.find(params[:id])
    # else
      @release = Release.find(params[:id])
    # end

    unless @release.user_allowed?(current_user)
      raise ActionController::RoutingError, 'Not Found'
    end

    @format = params[:format] || :mp3_320
    rf = ReleaseFile.find_by(release: @release, format: ReleaseFile.formats[@format])

    @release.tracks.each do |track|
      Download.create(user: current_user, track: track, format: Download.formats[@format], release: true)
    end

    redirect_to S3_BUCKET.object(rf.s3_key).presigned_url(:get, response_content_disposition: 'attachment')
  end

  def get_tracks
    release = Release.find(params[:id])
    @release_presenter = ReleasePresenter.new(release, current_user)

    if current_user && current_user.playlist.present?
      current_user.playlist.update_attributes(
        tracks: @release_presenter.tracks.map{|t| t[:id]}.join(','),
        current_track: "0:0")
    end
  end
end
