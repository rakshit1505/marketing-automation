class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, only: [:show, :update, :destroy]

  def index
    render json: find_accounts, status: 200
  end

  def show
    if @account.present?
      return success_response(@account)
    end
  end

  def update
    if own_account?
      if @account.update(permit_params)
        success_response(@account, status = 200)
      else
        error_response(@account)
      end
    else
      render json: {
            errors: [{
            message: "Not allowed"
            }]
        }, :status => :unauthorized
    end
  end

  def destroy
    @account = User.destroy(find_id[:id])

    if @account.destroy
      return render json: {
          id: find_id[:id],
          message: "Account deleted successfully"
      },
      status: 200
    else
      render json: { errors: format_activerecord_errors(@account.errors) }
    end
  end

  private

  def permit_params
    params.permit(:email,
                  :first_name,
                  :last_name,
                  :phone
                )
  end

  def set_account
    @account = User.find(params[:id])
    unless @account.present?
      return item_not_found('account', find_id[:id])
    end
  end

  def find_id
    params.permit(:id)
  end

  def own_account?
    current_account.id == find_id[:id]
  end

  def success_response(account, status = 200)
    render json: UserSerializer.new(account).
      serializable_hash,
      status: status
  end

  def error_response(account)
    render json: {
        errors: format_activerecord_errors(account.errors)
    },
    status: :unprocessable_entity
  end

  def index_params
    params.permit(:page, :per_page)
  end

  def find_accounts
    pagination_builder = PaginationBuilder.new(index_params[:page], index_params[:per_page])
    limit, offset = pagination_builder.paginate
    accounts = User.
      order(id: :asc).
      limit(limit).offset(offset)
    next_page = User.
      limit(1).offset(offset + limit).count
    data = serialized_accounts(accounts, next_page)
    merge_pagination_data(data, pagination_builder)
    data
  end

  def serialized_accounts(accounts, next_page)
    {
      next_page: next_page > 0,
      accounts: UserSerializer.new(accounts).
        serializable_hash
    }
  end

  def merge_pagination_data(data, pagination_builder)
    if pagination_builder.page == 1
      total_count = User.
        count
      total_pages = pagination_builder.total_pages(total_count)
      data.merge!({
        total_count: total_count,
        total_pages: total_pages
      })
    end
  end
end
