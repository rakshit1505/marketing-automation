class LeadAddressesController < ApplicationController
  before_action :set_lead_address, only: [:show, :update, :destroy]

  def create
    lead = Lead.find(create_params[:lead_id])

    lead_address = LeadAddress.new(create_params)

    begin
      lead_address.save
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(lead_address, :created)
  end

  def show
    return success_response(@lead_address)
  end

  def update
    success = false

    if update_params.present?
      begin
        success = @lead_address.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(@lead_address) unless success
    end
    return success_response(@lead_address) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy
    if @lead_address.destroy
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(@lead_address.errors) }
    end
  end

  def index
    render json: find_lead_addresses, status: 200
  end

  private

  def create_params
    params.require(:data)
      .permit(
        :lead_id,
        :street_address,
        :city,
        :state,
        :country,
        :zip_code
      )
  end

  def find_id
    params.permit(:id)
  end

  def update_params
    params.require(:data)
      .permit(
        :street_address,
        :city,
        :state,
        :country,
        :zip_code
      )
  end

  def set_lead_address
    @lead_address = LeadAddress.find(find_id[:id])
  end

  def success_response(lead_address, status = 200)
    render json: LeadAddressSerializer.new(lead_address).
      serializable_hash,
      status: status
  end

  def error_response(lead_address)
    render json: {
      errors: format_activerecord_errors(lead_address.errors)
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
    params.permit(:page, :per_page, :lead_id)
  end

  def find_lead_addresses
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    lead_addresses = LeadAddress.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = LeadAddress.
      limit(1).offset(offset + limit).count
    data = serialized_lead_addresses(lead_addresses, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_lead_addresses(lead_addresses, next_page)
    {
      next_page: next_page > 0,
      lead_addresses: LeadAddressSerializer.new(lead_addresses).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = LeadAddress.
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
