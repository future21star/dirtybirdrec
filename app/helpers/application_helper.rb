module ApplicationHelper
  
  def controller?(*controller)
    controller.include?(params[:controller])
  end

  def action?(*action)
    action.include?(params[:action])
  end

  def show_svg(path)
    File.open("app/assets/images/#{path}", "rb") do |file|
      raw file.read
    end
  end

  def get_track(track, current_user)
    if current_user && current_user.active_subscription?
      
    end
  end
end
