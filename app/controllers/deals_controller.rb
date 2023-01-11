class DealsController < ApplicationController
  before_action :set_deal, only: [:show, :update, :destroy]

  def create
    potential = Potential.find(params.permit(:id))

    deal = Deal.new(create_params)
    deal.current = current_user
    begin
      deal.save
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(deal, :created)
  end

  def show
    return success_response(@deal)
  end

  def update
    success = false
    if update_params.present?
      begin
        @deal.current = current_user
        success = @deal.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(@deal) unless success
    end
    return success_response(@deal) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy

    if @deal.destroy
      @deal.current = current_user
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(@deal.errors) }
    end
  end

  def index
    render json: find_deals, status: 200
  end

  private

  def create_params
    params.require(:data)
      .permit(
        :potential_id,
        :kick_off_date,
        :sign_off_date,
        :term,
        :tenure,
        :description,
        :status
      ).merge(
        user_id: current_user.id
      )
  end

  def update_params
    params.require(:data)
      .permit(
        :kick_off_date,
        :sign_off_date,
        :term,
        :tenure,
        :description,
        :status
      ).merge(
        user_id: current_user.id
      )
  end

  def set_deal
    @deal = Deal.find(find_id[:id])
  end

  def success_response(deal, status = 200)
    render json: DealSerializer.new(deal).
      serializable_hash,
      status: status
  end

  def error_response(deal)
    render json: {
      errors: format_activerecord_errors(deal.errors)
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

  def find_deals
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    deals = Deal.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = Deal.
      limit(1).offset(offset + limit).count
    data = serialized_deals(deals, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_deals(deals, next_page)
    {
      next_page: next_page > 0,
      deals: DealSerializer.new(deals).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = Deal.
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
