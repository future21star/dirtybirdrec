class AnnouncementsController < ApplicationController
  before_action :set_notifications

  def show
    @announcement = Announcement.find(params[:id])

    begin
      feed = StreamRails.feed_manager.get_feed('announcement', @announcement.id)
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed
      results = []
    end

    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results)
  end
end
