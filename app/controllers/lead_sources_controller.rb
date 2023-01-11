class LeadSourcesController < ApplicationController
  before_action :set_lead_source, only: [:show, :update, :destroy]

  def create
    lead_source = LeadSource.new(create_params)

    begin
      lead_source.save
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(lead_source, :created)
  end

  def show
    return success_response(@lead_source)
  end

  def update
    success = false

    if update_params.present?
      begin
        success = @lead_source.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(@lead_source) unless success
    end
    return success_response(@lead_source) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy
    if @lead_source.destroy
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(@lead_source.errors) }
    end
  end

  def index
    render json: find_lead_sources, status: 200
  end

  private

  def create_params
    params.require(:data)
      .permit(
        :name
      )
  end

  def find_id
    params.permit(:id)
  end

  def update_params
    params.require(:data)
      .permit(
        :name
      )
  end

  def set_lead_source
    @lead_source = LeadSource.find(find_id[:id])
  end

  def success_response(lead_source, status = 200)
    render json: LeadSourceSerializer.new(lead_source).
      serializable_hash,
      status: status
  end

  def error_response(lead_source)
    render json: {
      errors: format_activerecord_errors(lead_source.errors)
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

  def find_lead_sources
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    lead_sources = LeadSource.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = LeadSource.
      limit(1).offset(offset + limit).count
    data = serialized_lead_sources(lead_sources, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_lead_sources(lead_sources, next_page)
    {
      next_page: next_page > 0,
      lead_sources: LeadSourceSerializer.new(lead_sources).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = LeadSource.
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
