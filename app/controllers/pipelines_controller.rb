class PipelinesController < ApplicationController
  before_action :set_pipeline, only: [:show, :update, :destroy]

  def create
    lead_source = LeadSource.find(create_params[:lead_source_id])

    pipeline = Pipeline.new(create_params)

    begin
      pipeline.save
    rescue => errors
      return direct_error_response(errors)
    end
    return success_response(pipeline, :created)
  end

  def show
    return success_response(@pipeline)
  end

  def update
    success = false
    if update_params.present?
      begin
        success = @pipeline.update(update_params)
      rescue => errors
        return direct_error_response(errors)
      end
      return error_response(@pipeline) unless success
    end
    return success_response(@pipeline) if success
  end

  # ensure method is used to keep delete as idempotent
  def destroy
    if @pipeline.destroy
      return render json: {
          id: find_id[:id],
          message: "Record successfully deleted"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(@pipeline.errors) }
    end
  end

  def index
    render json: find_pipelines, status: 200
  end

  private

  def create_params
    params.require(:data)
      .permit(
        :lead_source_id,
        :account_name,
        :score,
        :journey,
        :probability,
        :expected_revenue
      ).merge(
        user_id: current_user.id
      )
  end

  def update_params
    params.require(:data)
      .permit(
        :account_name,
        :score,
        :journey,
        :probability,
        :expected_revenue,
        :lead_source_id
      ).merge(
        user_id: current_user.id
      )
  end

  def set_pipeline
    @pipeline = Pipeline.find(find_id[:id])
  end

  def find_id
    params.permit(:id)
  end

  def success_response(pipeline, status = 200)
    render json: PipelineSerializer.new(pipeline).
      serializable_hash,
      status: status
  end

  def error_response(pipeline)
    render json: {
      errors: format_activerecord_errors(pipeline.errors)
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

  def find_pipelines
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    pipelines = Pipeline.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = Pipeline.
      limit(1).offset(offset + limit).count
    data = serialized_pipelines(pipelines, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_pipelines(pipelines, next_page)
    {
      next_page: next_page > 0,
      pipelines: PipelineSerializer.new(pipelines).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = Pipeline.
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
