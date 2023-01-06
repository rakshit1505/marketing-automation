class Users::PasswordsController < ApplicationController
  skip_before_action :verify_authenticity_token
  respond_to :json  
  before_action :find_user
  before_action :find_otp, only: [:forgot]

  def forgot
    if @user.present?
      if @otp.present?
        @otp = update_otp(@otp)
      else
        @otp = create_otp(@user)
      end
      render json: {
        data: @user,
        otp_data: @user.otps.where(otp_type: @otp.otp_type).first,
        message: "The otp for the user has been created",
        success: true
        },
        status: :ok
    else
      #this sends regardless of whether there's an email in database for security reasons
      render json: {
        message: "No such account exist with this email or number",
        success: false
        },
        status: :unprocessable_entity
    end
   end

  def verify_otp
    otp = @user.otps.where(["otp_digits = ?", "#{params[:otp]}"]).first
    if otp.present?
      if otp.update(otp_verified: true)
        render json: {data: otp, message: "Otp has been verified", success: true}
      end
    else
      render json: {message: "Incorrect Otp"}, status: :unprocessable_entity
    end
   end

   def reset
    otp = @user.otps.where(["otp_token = ?", "#{params[:otp_token]}"]).first
    if otp.present? && otp.otp_verified
      if @user.update(password: params[:password])
        render json: {
          data: @user,
          message: "The Password is updated",
          success: true
        },
          status: :ok
      else
        render json: {
          message: "Password Cannot be updated",
          success: false
        },
          status: :unprocessable_entity
      end
    else
      render json: {message: "Otp not verified", success: false},  status: :unprocessable_entity
    end
   end

   private

   def update_otp(otp)
     otp.update(otp_digits: rand(1000..9999), otp_verified: false, otp_token: SecureRandom.hex)
   end

   def create_otp(user)
     user.otps.create(otp_digits: rand(1000..9999), otp_type: "forgot_password", otp_verified: false, otp_token: SecureRandom.hex)
   end

   def find_user
     forgot = params[:forgot]
     @user = User.find_by_email(forgot)
     unless @user
      @user = User.find_by_full_phone_number(forgot)
     end
    # @user = User.where("lower(email)  :q or CAST(full_phone_number AS TEXT)  :q", q: "%#{forgot}%").first
   end

   def find_otp
     type = params[:otp_type]
     if @user
      @otp = @user.otps.where(otp_type: type).first
     end
   end
end
