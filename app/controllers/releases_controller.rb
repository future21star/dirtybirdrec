class ReleasesController < ApplicationController
  def show
  end

  def index
    filters = params[:filters]
    @releases = Release.all

    @artists = User.with_role(:artist)

    if filters.present?
      filters.each do |filter, value|
        case filter
        when 'never_released' 
          @releases = @releases.where("release_date > ? OR release_date = NULL", Date.today)
        when 'month' 
          @releases = @releases.where("release_date > ? AND release_date < ?", Date.today - 1.month, Date.today)
        when 'year' 
          @releases = @releases.where("release_date > ? AND release_date < ?", Date.today - 1.year, Date.today)
        when 'artist' 
          @releases = @releases.where("artist_id = ?", value)
        when 'not_downloaded' 
          @releases = @releases.where("release_date > ? OR release_date = NULL")
        end
      end
    end
  end
end
