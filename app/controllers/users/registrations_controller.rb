class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token
  respond_to :json
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    case params[:type] #### rescue invalid API format
    when 'sms_account'
      phone = params[:full_phone_number]
      if phone.present?
        otp_data = SmsOtp.new(full_phone_number: phone)
        otp_data.save
        token = serialized_phone_otp(otp_data)
        render json:  [ { sms_otp: otp_data }, meta: { token: token } ], status: :created
      else
        render json: {errors: format_activerecord_errors(otp_data.errors)},
          status: :unprocessable_entity
      end
    when 'email_account'


    else
      render json: { errors: [
        { account: 'Invalid Account Type' },
      ] }, status: :unprocessable_entity
    end
  end

 
  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.

  # def cancel
  #   super
  # end

  # protected

  private

  def format_activerecord_errors(errors)
    result = []
    errors.each do |attribute, error|
      result << { attribute => error }
    end
    result
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        data: UserSerializer.new(resource).serializable_hash, message: 'Signed up sucessfully.', success: true },
        status: :ok
    else
      render json: {
        message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}", success: false},
        status: :unprocessable_entity
    end
  end

  # If you have extra params to permit, append them to the sanitizer.

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_phone_number, :type, :email, :password, :full_name])
  end

  # If you have extra params to permit, append them to the sanitizer.

  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  #encoding sms_otp with jwt
  def serialized_phone_otp(otp_data)
    payload = { id: otp_data.id,
    exp: 30.minutes.from_now.to_i,
   type: "sms_otp"
       }
    token= JWT.encode( payload , Rails.application.secret_key_base)
    return token
  end

end
