class AnnouncementsController < ApplicationController
  def show
    @announcement = Announcement.find(params[:id])

    feed = StreamRails.feed_manager.get_feed('announcement', @announcement.id)
    results = feed.get()['results']
    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results)
  end
end
