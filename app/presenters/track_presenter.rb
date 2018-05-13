class TrackPresenter < SimpleDelegator
  def initialize(track, current_user = nil)
    @track = track
    @current_user = current_user
    __setobj__(track)
    @is_sample = !(current_user && current_user.active_subscription?)
    # @is_sample = !true #TODO REMOVE IT
  end

  def stream_uri
    __getobj__.stream_uri(is_sample)
  end

  def download_uris
    return {} if is_sample
    __getobj__.download_uris
  end

  private

  attr_accessor :current_user, :track, :is_sample
end
