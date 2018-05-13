class ReleasesController < ApplicationController
  def show
    @release = Release.find(params[:id])

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
    @releases = Release.released.all

    @artists = User.with_role(:artist)

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
  end

  def download
    redirect_to new_user_registration_path and return unless current_user
    redirect_to choose_profile_path and return if current_user.subscription_type.blank?

    @release = Release.find(params[:id])
    redirect_to choose_profile_path unless @release.user_allowed?(current_user)
  end

  def get_tracks
    release = Release.find(params[:id])
    @release_presenter = ReleasePresenter.new(release, current_user)
  end
end
