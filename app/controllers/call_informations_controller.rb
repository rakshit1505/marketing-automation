class CallInformationsController < ApplicationController
  before_action :find_call_type_and_lead, only: [:create]
  before_action :set_call_information, only: [:show, :update, :destroy]

  def create
    call_information = CallInformation.new(create_params)

    begin
      call_information.save
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(call_information, :created)
  end

  def show
    return success_response(@call_information)
  end

  def update
    success = false

    if update_params.present?
      begin
        success = @call_information.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(@call_information) unless success
    end
    return success_response(@call_information) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy
    if @call_information.destroy
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(@call_information.errors) }
    end
  end

  def index
    render json: find_call_informations, status: 200
  end

  private

  def create_params
    params.require(:data)
      .permit(
        :call_type_id,
        :lead_id,
        :start_time,
        :call_owner,
        :subject,
        :status,
        :reminder
      ).merge(
        user_id: current_user.id
      )
  end

  def find_id
    params.permit(:id)
  end

  def update_params
    params.require(:data)
      .permit(
        :start_time,
        :call_owner,
        :subject,
        :status,
        :reminder
      )
  end

  def find_call_type_and_lead
    call_type = CallType.find(create_params[:call_type_id])
    lead = Lead.find(create_params[:lead_id])
  end

  def set_call_information
    @call_information = CallInformation.find(find_id[:id])
  end

  def success_response(call_information, status = 200)
    render json: CallInformationSerializer.new(call_information).
      serializable_hash,
      status: status
  end

  def error_response(call_information)
    render json: {
      errors: format_activerecord_errors(call_information.errors)
    },
    status: :unprocessable_entity
  end

  def direct_error_response(errors)
    render json: {
      errors: errors
    },
    status: :unprocessable_entity
  end

  def not_found(type = '')
    render json: {
      type: type,
      errors: 'Not Found'
    },
    status: :not_found
  end

  def index_params
    params.permit(:page, :per_page, :call_type_id, :lead_id)
  end

  def find_call_informations
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    call_informations = CallInformation.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = CallInformation.
      limit(1).offset(offset + limit).count
    data = serialized_call_informations(call_informations, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_call_informations(call_informations, next_page)
    {
      next_page: next_page > 0,
      call_informations: CallInformationSerializer.new(call_informations).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = CallInformation.
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
