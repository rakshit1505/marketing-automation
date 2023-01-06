class TasksController < ApplicationController
  before_action :set_task, only: [:show, :update, :destroy]

  def create
    task = Task.new(create_params)

    begin
      task.save
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(task, :created)
  end

  def show
    return success_response(@task)
  end

  def update
    success = false

    if update_params.present?
      begin
        success = @task.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(@task) unless success
    end
    return success_response(@task) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy
    if @task.destroy
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(@task.errors) }
    end
  end

  def index
    render json: find_tasks, status: 200
  end

  private

  def create_params
    params.require(:data)
      .permit(
        :last_name,
        :due_date_time,
        :priority,
        :integer
      ).merge(
        task_owner: current_user
      )
  end

  def find_id
    params.permit(:id)
  end

  def update_params
    params.require(:data)
      .permit(
        :last_name,
        :due_date_time,
        :priority,
        :integer
      )
  end

  def set_task
    @task = Task.find(find_id[:id])
  end

  def success_response(task, status = 200)
    render json: TaskSerializer.new(task).
      serializable_hash,
      status: status
  end

  def error_response(task)
    render json: {
      errors: format_activerecord_errors(task.errors)
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

  def find_tasks
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    tasks = Task.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = Task.
      limit(1).offset(offset + limit).count
    data = serialized_tasks(tasks, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_tasks(tasks, next_page)
    {
      next_page: next_page > 0,
      tasks: TaskSerializer.new(tasks).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = Task.
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
