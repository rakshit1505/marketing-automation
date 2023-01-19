class ManageDataController < ApplicationController

  before_action :set_manage_data, only: [:show, :update, :destroy]


def create
  manage_data = ManageData.new(create_params)

  begin
    manage_data.save
  rescue => errors
    return direct_error_response(errors)
  end
  return success_response(manage_data, :created)
end

def update
 success = false

    if update_params.present?
      begin
        success = @manage_data.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(@manage_data) unless success
    end
    return success_response(@manage_data) if success
  end

end

def set_default


end

def show 
    return success_response(@manage_data)
end


private


def set_manage_data
    @manage_data = ManageData.find(user_id: current_user.id)
end

def direct_error_response(errors)
    render json: {
      errors: errors
    },
    status: :unprocessable_entity
 end

def success_response(manage_data, status = 200)
    render json: manage_data,
      status: status
end

def create_params
    params.require(:data)
      .permit(
        :field_name => []
      ).merge(
        user_id: current_user.id
      )
  end

 def update_params
    params.require(:data)
      .permit( :field_name => []
      )
  end





end
