class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user, :except => [:attempt_login, :login, :logout]
  before_filter :save_login_state, :only => [:attempt_login, :login]
  
	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end

	helper_method :current_user

	protected 
	
	def authenticate_user
		#raise params.to_yaml
		if session[:user_id]
		  current_user 
		  return true	
		else
		  redirect_to('/login')
		  return false
		end
	end
	
	def save_login_state
		if session[:user_id]
		  redirect_to(:controller => 'htcs', :action => 'index')
		  return false
		else
		  return true
		end
	end

end
