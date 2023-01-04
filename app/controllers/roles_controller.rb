roleclass RolesController < ApplicationController
  include ErrorHandler

  def create
    role = Role.new(create_params)

    begin
      role.save
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(role, :created)
  end

  def show
    begin
      role = Role.find(find_id[:id])
      return success_response(role)
    rescue ActiveRecord::RecordNotFound
      return item_not_found('role', find_id[:id])
    end
  end

  def update
    success = false
    begin
      role = Role.find(find_id[:id])
    rescue
      return item_not_found('role', find_id[:id])
    end
    if update_params.present?
      begin
        success = role.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(role) unless success
    end
    return success_response(role) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy
    begin
      role = Role.find(find_id[:id])
    rescue ActiveRecord::RecordNotFound
      return item_not_found('role', find_id[:id])
    end

    if role.destroy
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(role.errors) }
    end
  end

  def index
    render json: find_roles, status: 200
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

  def success_response(role, status = 200)
    render json: RoleSerializer.new(role).
      serializable_hash,
      status: status
  end

  def error_response(role)
    render json: {
      errors: format_activerecord_errors(role.errors)
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

  def find_roles
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    roles = Role.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = Role.
      limit(1).offset(offset + limit).count
    data = serialized_roles(roles, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_roles(roles, next_page)
    {
      next_page: next_page > 0,
      roles: RoleSerializer.new(roles).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = Role.
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end