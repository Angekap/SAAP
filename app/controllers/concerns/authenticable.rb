module Concerns
  module Authenticable
    extend ActiveSupport::Concern

    included do
      before_action :require_authentication
      helper_method :current_user
    end

    protected
    def sign_in(user)
      session[:user_id] = user.id
      @current_user = user
      return_url = session[:back_to_url] || root_path
      session[:back_to_url] = nil
      redirect_to return_url
    end

    def sign_out(user)
      session[:user_id] = nil
      @current_user = nil
      redirect_to root_path
    end

    def current_user
      @current_user ||= (session[:user_id] && User.find(session[:user_id]))
    end

    def require_authentication
      session[:back_to_url] = request.original_url
      redirect_to new_session_path unless current_user
    end

    def require_no_authentication
      redirect_to new_sessions_path if current_user
    end
  end
end