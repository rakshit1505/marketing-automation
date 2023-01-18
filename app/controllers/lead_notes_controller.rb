class LeadNotesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_lead
  before_action :set_note, only: [:show, :update, :destroy]
  before_action :authenticate_user!

  def create
    lead_notes = @lead.notes.new(create_params)

    begin
      lead_notes.save!
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(lead_notes, :created)
  end

  def show
    return success_response(@note)
  end

  def update
    success = false

    if update_params.present?
      begin
        success = @note.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(@note) unless success
    end
    return success_response(@note) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy
    if @note.destroy
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(@note.errors) }
    end
  end

  def index
    render json: find_notes, status: 200
  end

  private

  def create_params
    params.require(:data)
      .permit(
        :title,
        :description,
        :attachment_id,
        :lead_id
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
        :title,
        :description,
        :attachment_id,
        :lead_id,
        :notable_id,
        :notable_type
      ).merge(
        user_id: current_user.id
      )
  end

  def set_lead
    @lead = Lead.where(id: params[:lead_id]).first || Lead.where(id: params[:data][:lead_id]).first
  end

  def set_note
    @note = @lead.notes.where(id: find_id[:id]).first
  end

  def success_response(note, status = 200)
    render json: NoteSerializer.new(note).
      serializable_hash,
      status: status
  end

  def error_response(note)
    render json: {
      errors: format_activerecord_errors(note.errors)
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

  def find_notes
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    notes = @lead.notes.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = @lead.notes.
      limit(1).offset(offset + limit).count
    data = serialized_notes(notes, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_notes(notes, next_page)
    {
      next_page: next_page > 0,
      notes: NoteSerializer.new(notes).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = @lead.notes.
                    count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
