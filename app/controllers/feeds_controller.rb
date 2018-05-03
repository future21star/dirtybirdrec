class FeedsController < ApplicationController
  before_action :create_enricher
  before_action :authenticate_user!

  def is_seen
    begin
      feed = StreamRails.feed_manager.get_notification_feed(current_user.id)
      results = feed.get(mark_seen: true)
    rescue Faraday::Error::ConnectionFailed
      results = []
    end


    render json: {}, status: :ok
  end

  private

    def create_enricher
      @enricher = StreamRails::Enrich.new
    end

end
