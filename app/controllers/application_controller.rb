class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # https://github.com/plataformatec/devise/pull/4033/files
  protect_from_forgery with: :exception, prepend: true

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    if resource.has_role?(:voter, :any)
      existing = resource.open_ride
      return edit_ride_path(existing) if existing

      # TODO: handle es path
      return "/get_a_ride/#{resource.voter_ride_zone_id}"
    end
    root_path
  end

  protected

  def set_locale
    if request.path.include?('conseguir_un_paseo')
      I18n.locale = 'es'
    elsif params[:locale].present?
      I18n.locale = params[:locale]
    else
      I18n.locale = I18n.default_locale
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:user_type, :name, :email, :phone_number, :zip, :city, :state, :city_state, :ride_zone_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_ride_zone
    @ride_zone = RideZone.find(params[:id])
  end

  def require_zone_privilege
    unless user_signed_in? &&
      ( current_user.has_role?(:admin) ||
        current_user.has_role?(:admin, @ride_zone) ||
        current_user.has_role?(:dispatcher, @ride_zone)
      )
      redirect_to '/404.html'
    end
  end

end
