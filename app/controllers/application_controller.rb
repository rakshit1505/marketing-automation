class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_error
  respond_to :json
  include ActionController::MimeResponds


 #for audit logs 
  around_filter :set_logger_username

  def set_logger_username
    Thread.current["username"] = current_user.login || "guest"
    yield
    Thread.current["username"] = nil
  end
 # audit log 

  def record_not_found_error(exception)
    render json: { errors: exception }, status: :unprocessable_entity
  end

  def format_activerecord_errors(errors)
      result = []
      errors.each do |attribute, error|
          result << { attribute => error }
      end
      result
  end

  # def item_not_found(type, id)
  #   render json: {
  #       errors: [{
  #       "#{type}" => "Record with id= #{id} not found"
  #       }]
  #   },
  #   status: :unprocessable_entity
  # end
end
