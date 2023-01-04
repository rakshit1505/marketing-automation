class CallTypesController < ApplicationController
  include ErrorHandler

  def create
    call_type = CallType.new(create_params)

    begin
      call_type.save
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(call_type, :created)
  end

  def show
    begin
      call_type = CallType.find(find_id[:id])
      return success_response(call_type)
    rescue ActiveRecord::RecordNotFound
      return item_not_found('call_type', find_id[:id])
    end
  end

  def update
    success = false
    begin
      call_type = CallType.find(find_id[:id])
    rescue
      return item_not_found('call_type', find_id[:id])
    end
    if update_params.present?
      begin
        success = call_type.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(call_type) unless success
    end
    return success_response(call_type) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy
    begin
      call_type = CallType.find(find_id[:id])
    rescue ActiveRecord::RecordNotFound
      return item_not_found('call_type', find_id[:id])
    end

    if call_type.destroy
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(call_type.errors) }
    end
  end

  def index
    render json: find_call_types, status: 200
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

  def success_response(call_type, status = 200)
    render json: CallTypeSerializer.new(call_type).
      serializable_hash,
      status: status
  end

  def error_response(call_type)
    render json: {
      errors: format_activerecord_errors(call_type.errors)
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

  def find_call_types
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    call_types = CallType.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = CallType.
      limit(1).offset(offset + limit).count
    data = serialized_call_types(call_types, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_call_types(call_types, next_page)
    {
      next_page: next_page > 0,
      call_types: CallTypeSerializer.new(call_types).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = CallType.
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
