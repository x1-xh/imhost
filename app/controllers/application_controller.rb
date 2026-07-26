class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :check_root_user_setup

  private

  def check_root_user_setup
    return if request.path == rails_health_check_path || request.path == '/up'

    if User.count == 0 && request.path != setup_path && request.path != setup_create_path
      redirect_to setup_path
    end
  end
end
