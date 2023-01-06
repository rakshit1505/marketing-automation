class CallAgendasController < ApplicationController
  before_action :set_call_agenda, only: [:show, :update, :destroy]

  def create
    begin
      call_information = CallInformation.find(create_params[:call_information_id])
    rescue
      return item_not_found('call_information', create_params[:call_information_id]) if call_information.blank?
    end

      call_agenda = CallAgenda.new(create_params)

      begin
        call_agenda.save
      rescue => errors
        return direct_error_response(errors)
      end
      return success_response(call_agenda, :created)
  end

  def show
    return success_response(@call_agenda)
  end

  def update
    success = false

    if update_params.present?
      begin
        success = @call_agenda.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(@call_agenda) unless success
    end
    return success_response(@call_agenda) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy
    if @call_agenda.destroy
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(@call_agenda.errors) }
    end
  end

  def index
    render json: find_call_agendas, status: 200
  end

  private

  def create_params
    params.require(:data)
      .permit(
        :call_information_id,
        :objective,
        :description
      )
  end

  def find_id
    params.permit(:id)
  end

  def update_params
    params.require(:data)
      .permit(
        :objective,
        :description
      )
  end

  def set_call_agenda
    @call_agenda = CallAgenda.find(find_id[:id])
  end

  def success_response(call_agenda, status = 200)
    render json: CallAgendaSerializer.new(call_agenda).
      serializable_hash,
      status: status
  end

  def error_response(call_agenda)
    render json: {
      errors: format_activerecord_errors(call_agenda.errors)
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
    params.permit(:page, :per_page, :call_information_id)
  end

  def find_call_agendas
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    call_agendas = CallAgenda.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = CallAgenda.
      limit(1).offset(offset + limit).count
    data = serialized_call_agendas(call_agendas, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_call_agendas(call_agendas, next_page)
    {
      next_page: next_page > 0,
      call_agendas: CallAgendaSerializer.new(call_agendas).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = CallAgenda.
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
