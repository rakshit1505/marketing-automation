class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :update, :destroy]

  def create
    department = Department.new(create_params)

    begin
      department.save
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(department, :created)
  end

  def show
    return success_response(@department)
  end

  def update
    success = false

    if update_params.present?
      begin
        success = @department.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(@department) unless success
    end
    return success_response(@department) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy
    if @department.destroy
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(@department.errors) }
    end
  end

  def index
    render json: find_departments, status: 200
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

  def set_department
    @department = Department.find(find_id[:id])
  end

  def success_response(department, status = 200)
    render json: DepartmentSerializer.new(department).
      serializable_hash,
      status: status
  end

  def error_response(department)
    render json: {
      errors: format_activerecord_errors(department.errors)
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

  def find_departments
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    departments = Department.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = Department.
      limit(1).offset(offset + limit).count
    data = serialized_departments(departments, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_departments(departments, next_page)
    {
      next_page: next_page > 0,
      departments: DepartmentSerializer.new(departments).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = Department.
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
