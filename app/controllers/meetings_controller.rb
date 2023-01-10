class MeetingsController < ApplicationController
  before_action :set_meeting, only: [:show, :update, :destroy]

  def create
    meeting = Meeting.new(create_params)

    begin
      meeting.save
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(meeting, :created)
  end

  def show
    return success_response(@meeting)
  end

  def update
    success = false

    if update_params.present?
      begin
        success = @meeting.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(@meeting) unless success
    end
    return success_response(@meeting) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy
    if @meeting.destroy
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(@meeting.errors) }
    end
  end

  def index
    render json: find_meetings, status: 200
  end

  private

  def create_params
    params.require(:data)
      .permit(
        :title,
        :type_of_meeting,
        :is_online,
        :duration,
        :description,
        :reminder,
        :agenda,
        :status
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
        :type_of_meeting,
        :is_online,
        :duration,
        :description,
        :reminder,
        :agenda,
        :status
      )
  end

  def set_meeting
    @meeting = Meeting.find(find_id[:id])
  end

  def success_response(meeting, status = 200)
    render json: MeetingSerializer.new(meeting).
      serializable_hash,
      status: status
  end

  def error_response(meeting)
    render json: {
      errors: format_activerecord_errors(meeting.errors)
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

  def find_meetings
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    meetings = Meeting.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = Meeting.
      limit(1).offset(offset + limit).count
    data = serialized_meetings(meetings, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_meetings(meetings, next_page)
    {
      next_page: next_page > 0,
      meetings: MeetingSerializer.new(meetings).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = Meeting.
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
