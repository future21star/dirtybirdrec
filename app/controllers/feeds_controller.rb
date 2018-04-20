class FeedsController < ApplicationController
  before_action :create_enricher
  before_action :authenticate_user!

  def is_seen
    feed = StreamRails.feed_manager.get_notification_feed(current_user.id)
    results = feed.get(mark_seen: true)

    render json: {}, status: :ok
  end

  private

    def create_enricher
      @enricher = StreamRails::Enrich.new
    end

end
