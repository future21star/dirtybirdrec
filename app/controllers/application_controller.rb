class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_online

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  rescue_from ActiveRecord::RecordNotUnique, :with => :record_not_uniq  

  helper_method :resource_name, :resource, :devise_mapping, :resource_class

  def resource_name
    :user
  end
  
  def resource
    @resource ||= User.new
  end

  def resource_class
    User
  end
  
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def set_notifications
    if current_user
      begin
        feed = StreamRails.feed_manager.get_notification_feed(current_user.id)
        results = feed.get(limit: 20)['results']
      rescue Faraday::Error::ConnectionFailed
        results = []
      end

      results = results.each { |r| r['activities'].delete_if { |a| a['actor'] == "User:#{current_user.id}" } }
      results = results.delete_if { |r| r['activities'].count == 0 }

      results.each do |r| 
        r['activity_count'] = r['activities'].count
        r['actor_count'] = r['activities'].pluck('actor').uniq.count
      end

      unseen = results.select { |r| r['is_seen'] == false }
      @unseen_count = unseen.count
      @enricher = StreamRails::Enrich.new

      if @unseen_count <= 8
        @notify_activities = @enricher.enrich_aggregated_activities(results[0..7])
      else
        @notify_activities = @enricher.enrich_aggregated_activities(unseen)
      end
    end
  end

  protected

    def admin_controller?
      return params[:controller].match(/^admin\//).present?
    end

    def set_online
      if current_user
        begin
          $redis_onlines.set( current_user.id, nil, ex: 60 )
        rescue Redis::CannotConnectError
          return false
        end
      end
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :provider, :uid])
      devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :provider, :uid])
    end

    def record_not_uniq
      redirect_back(fallback_location: root_path)
    end

end
