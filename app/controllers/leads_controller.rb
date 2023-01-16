class LeadsController < ApplicationController

  require "create_lead.rb"

  before_action :find_require_ids, only: [:create]
  before_action :set_lead, only: [:show, :update, :destroy]

  def create
    leads_arr = params[:leads]
    start_ind = 1

    response = CreateLead.iterate_lead(leads_arr, start_ind)

    if response[:errors].present?
      return render json: {errors: response[:errors]}, status: :unprocessable_entity
    else
      render json: ActiveModel::ArraySerializer.new(response[:leads], each_serializer: LeadSerializer).as_json, status: :ok
    end
  end

  def update_reps
    leads_arr = params[:leads]
    start_ind = 1

    response = CreateLead.iterate_lead(leads_arr, start_ind)
    
    if response[:errors].present?
      return render json: {errors: response[:errors]}, status: :unprocessable_entity
    else
      render json: ActiveModel::ArraySerializer.new(response[:leads], each_serializer: LeadSerializer).as_json, status: :ok
    end
    
  end

  def show
    return success_response(@lead)
  end


  # ensure method is used to keep delete as idempotent
  def destroy
    if @lead.destroy
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
    @leads = Lead.all
    filter_items if @leads.exists?
    render json: @leads, status: 200
  end

  def download_template
      ActiveRecord::Base.transaction do
        data = DownloadTemplateService.new.excel_template
        file = File.new("lead.xlsx", "wb")
        file.write(data.to_stream.read)
        file.close
        send_file(file.path, :type => 'xlsx', :disposition => 'inline')
      end
  end

  def file_upload
    file = params[:file]
    return render json: {errors: "No file present"}, status: :unprocessable_entity unless file.present?
    file_ext = File.extname(file.original_filename)
    return render json: {errors: "Unknown file type. File format must be a csv, xls or xlsx"}, status: :unprocessable_entity unless file_ext == ".xls" || file_ext == ".xlsx"
    response = Lead.import_file_data(file)

    if response[:errors].present?
      return render json: {errors: response[:errors]}, status: :unprocessable_entity
    else
      render json: { message: "Leads uploaded succesfully!" }
    end
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

  def filter_items
    start_date = params[:date_from]&.to_date&.beginning_of_day
    end_date = params[:date_to]&.to_date&.end_of_day
    if start_date.present? && end_date.present? && params[:filter_by].present? 
      @leads = @leads.where(created_at: start_date..end_date) if params[:filter_by] == "created_at"
      @leads = @leads.where(updated_at: start_date..end_date) if params[:filter_by] == "last_modification"
    end
    @leads = @leads.where(lead_source_id: (params[:data][:lead_source_id])) unless params[:lead_source_id].blank?
    @leads = @leads.where(status_id: (params[:data][:status_ids])) unless params[:status_ids].blank?
    @leads = @leads.where(industry: (params[:data][:industry])) unless params[:industry].blank?
    @leads = @leads.where(company_size: (params[:data][:company_size])) unless params[:company_size].blank?
  end
end
