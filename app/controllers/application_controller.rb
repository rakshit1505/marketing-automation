class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  respond_to :json
  include ActionController::MimeResponds

  around_filter :set_logger_username

  def set_logger_username
    Thread.current["username"] = current_user.login || "guest"
    yield
    Thread.current["username"] = nil
  end
end
