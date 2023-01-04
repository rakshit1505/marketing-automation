class LeadsController < ApplicationController
  include ErrorHandler

  def create
    begin
      lead_source = LeadSource.find(find_lead_source_id)
    rescue
      return item_not_found('lead_source', find_lead_source_id) if lead_source.blank?
    end
    begin
      lead_status = LeadStatus.find(find_lead_status_id)
    rescue
      return item_not_found('lead_status', find_lead_status_id) if lead_status.blank?
    end
    begin
      lead_rating = LeadRating.find(find_lead_rating_id)
    rescue
      return item_not_found('lead_rating', find_lead_rating_id) if lead_rating.blank?
    end
    lead = Lead.new(create_params)

    begin
      lead.save
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(lead, :created)
  end

  def show
    begin
      lead = Lead.find(find_id[:id])
      return success_response(lead)
    rescue ActiveRecord::RecordNotFound
      return item_not_found('lead', find_id[:id])
    end
  end

  def update
    success = false
    begin
      lead = Lead.find(find_id[:id])
    rescue
      return item_not_found('lead', find_id[:id])
    end
    if update_params.present?
      begin
        success = lead.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(lead) unless success
    end
    return success_response(lead) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy
    begin
      lead = Lead.find(find_id[:id])
    rescue ActiveRecord::RecordNotFound
      return item_not_found('lead', find_id[:id])
    end

    if lead.destroy
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(lead.errors) }
    end
  end

  def index
    render json: find_leads, status: 200
  end

  private

  def create_params
    params.require(:data)
      .permit(
        :first_name,
        :last_name,
        :email_id,
        :phone_number,
        :company_id,
        :title,
        :lead_source_id,
        :lead_rating_id,
        :lead_status_id,
        :industry,
        :company_size,
        :website,
        :address_id
      )
  end

  def find_id
    params.permit(:id)
  end

  def find_lead_rating_id
    create_params[:lead_rating_id]
  end

  def find_lead_source_id
    create_params[:lead_source_id]
  end

  def find_lead_status_id
    create_params[:lead_status_id]
  end

  def update_params
    params.require(:data)
      .permit(
        :first_name,
        :last_name,
        :email_id,
        :phone_number,
        :company_id,
        :title,
        :lead_source_id,
        :lead_rating_id,
        :lead_status_id,
        :industry,
        :company_size,
        :website,
        :address_id
      )
  end

  def success_response(lead, status = 200)
    render json: LeadSerializer.new(lead).
      serializable_hash,
      status: status
  end

  def error_response(lead)
    render json: {
      errors: format_activerecord_errors(lead.errors)
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

  def find_leads
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    leads = Lead.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = Lead.
      limit(1).offset(offset + limit).count
    data = serialized_leads(leads, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_leads(leads, next_page)
    {
      next_page: next_page > 0,
      leads: LeadSerializer.new(leads).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = Lead.
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
