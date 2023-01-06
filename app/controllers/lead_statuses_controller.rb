class LeadStatusesController < ApplicationController
  before_action :set_lead_status, only: [:show, :update, :destroy]

  def create
    lead_status = LeadStatus.new(create_params)

    begin
      lead_status.save
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(lead_status, :created)
  end

  def show
    return success_response(@lead_status)
  end

  def update
    success = false

    if update_params.present?
      begin
        success = @lead_status.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(@lead_status) unless success
    end
    return success_response(@lead_status) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy
    if @lead_status.destroy
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(@lead_status.errors) }
    end
  end

  def index
    render json: find_lead_statuses, status: 200
  end

  private

  def create_params
    params.require(:data)
      .permit(
        :name
      )
  end

  def find_id[:id]
    params.permit(:id)
  end

  def update_params
    params.require(:data)
      .permit(
        :name
      )
  end

  def set_lead_status
    @lead_status = LeadStatus.find(find_id[:id])
  end

  def success_response(lead_status, status = 200)
    render json: LeadStatusSerializer.new(lead_status).
      serializable_hash,
      status: status
  end

  def error_response(lead_status)
    render json: {
      errors: format_activerecord_errors(lead_status.errors)
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
    params.permit(:page, :per_page)
  end

  def find_lead_statuses
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    lead_statuses = LeadStatus.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = LeadStatus.
      limit(1).offset(offset + limit).count
    data = serialized_lead_statuses(lead_statuses, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_lead_statuses(lead_statuses, next_page)
    {
      next_page: next_page > 0,
      lead_statuses: LeadStatusSerializer.new(lead_statuses).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = LeadStatus.
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
