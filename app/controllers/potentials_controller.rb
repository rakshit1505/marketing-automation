class PotentialsController < ApplicationController
  before_action :set_potential, only: [:show, :update, :destroy]

  def create
    lead = Lead.find(create_params[:lead_id])

    potential = Potential.new(create_params.merge(company_id: lead.company_id))
    potential.current = current_user

    begin
      potential.save
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(potential, :created)
  end

  def show
    return success_response(@potential)
  end

  def update
    success = false
    if update_params.present?
      begin
        @potential.current = current_user
        success = @potential.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(@potential) unless success
    end
    return success_response(@potential) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy

    if @potential.destroy
      @potential.current = current_user
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(@potential.errors) }
    end
  end

  def index
    render json: find_potentials, status: 200
  end

  private

  def create_params
    params.require(:data)
      .permit(
        :lead_id,
        :outcome,
        :status,
        :amount,
        :company_id
      ).merge(
        user_id: current_user.id
      )
  end

  def update_params
    params.require(:data)
      .permit(
        :outcome,
        :status,
        :amount,
        :company_id
      ).merge(
        user_id: current_user.id
      )
  end

  def set_potential
    @potential = Potential.find(find_id[:id])
  end

  def find_id
    params.permit(:id)
  end

  def success_response(potential, status = 200)
    render json: PotentialSerializer.new(potential).
      serializable_hash,
      status: status
  end

  def error_response(potential)
    render json: {
      errors: format_activerecord_errors(potential.errors)
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
    params.permit(:page, :per_page, :potential)
  end

  def find_potentials
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    potentials = Potential.
      search_potential(index_params[:potential]).
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = Potential.
      search_potential(index_params[:potential]).
      limit(1).offset(offset + limit).count
    data = serialized_potentials(potentials, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_potentials(potentials, next_page)
    {
      next_page: next_page > 0,
      potentials: PotentialSerializer.new(potentials).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = Potential.
        search_potential(index_params[:potential]).
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
