class LeadsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :find_require_ids, only: [:create]
  before_action :set_lead, only: [:show, :update, :destroy]
  before_action :authenticate_user!

  def create
    lead = Lead.new(create_params)
    lead.current = current_user
    begin
      lead.save!
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(lead, :created)
  end

  def show
    return success_response(@lead)
  end

  def update
    success = false

    if update_params.present?
      begin
        @lead.current = current_user
        success = @lead.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(@lead) unless success
    end
    return success_response(@lead) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy
    if @lead.destroy
     @lead.current = current_user
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(@lead.errors) }
    end
  end

  def index
    render json: find_leads, status: 200
  end

  def lead_mass_delete
    leads = Lead.where(id: delete_params[:lead_ids])
    leads.each do |lead|
      lead.destroy
      lead.current = current_user
    end
    return render json: {
          id: delete_params[:lead_ids],
          message: 'Leads successfully deleted'
      },
      status: 200
  end

  def lead_mass_transfer
    user = User.find(lead_params[:user_id])
    leads = Lead.where(id: lead_params[:lead_ids]).update_all(user_id: lead_params[:user_id], updated_at: Time.now)
    return render json: {
          lead_id: lead_params[:lead_ids],
          user_id: lead_params[:user_id],
          message: 'Lead successfully transfered'
      },
      status: 200
  end

  def lead_mass_convert
    leads = Lead.where(id: lead_params[:lead_ids])

    leads.each do |lead|
      Potential.create!(lead_id: lead.id, user_id: current_user&.id, company_id: lead&.company_id) if lead_params[:convert_to] == 'potential'
      Deal.create!(user_id: current_user&.id) if lead_params[:convert_to] == 'deal'
    end

    return render json: {
          lead_id: lead_params[:lead_ids],
          user_id: current_user&.id,
          message: lead_params[:convert_to] == 'deal' ? 'Lead successfully transfered to deal' : 'Lead successfully transfered to potential'
      },
      status: 200
  end

  private

  def create_params
    params.require(:data)
      .permit(
        :first_name,
        :last_name,
        :email,
        :phone_number,
        :company_id,
        :title,
        :lead_source_id,
        :lead_rating_id,
        :industry,
        :company_size,
        :website,
        :address_id
      )
  end

  def find_id
    params.permit(:id)
  end

  def delete_params
    params.require(:data)
      .permit(
        lead_ids:[]
      )
  end

  def lead_params
    params.require(:data)
      .permit(
        :user_id,
        :convert_to,
        lead_ids:[]
      )
  end

  def update_params
    params.require(:data)
      .permit(
        :first_name,
        :last_name,
        :email,
        :phone_number,
        :company_id,
        :title,
        :lead_source_id,
        :lead_rating_id,
        :industry,
        :company_size,
        :website,
        :address_id
      )
  end

  def set_lead
    @lead = Lead.find(find_id[:id])
  end

  def find_require_ids
    lead_source = LeadSource.find(create_params[:lead_source_id])
    # lead_status = LeadStatus.find(create_params[:lead_status_id])
    # lead_rating = LeadRating.find(create_params[:lead_rating_id])
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
    params.permit(:page, :per_page, :lead, :user_id)
  end

  def find_leads
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    leads = Lead.
      search(index_params).
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = Lead.
      search(index_params).
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
                    search(index_params).
                    count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
