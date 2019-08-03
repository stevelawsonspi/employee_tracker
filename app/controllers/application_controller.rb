class ApplicationController < ActionController::Base
  include Pagy::Backend
  
  def set_current_business(business_id)
    session[:current_business] = business_id
    @current_business = nil
  end
  helper_method :set_current_business

  def current_business
    @current_business ||= session[:current_business] ? Business.find(session[:current_business]) : nil
  end
  helper_method :current_business
end
