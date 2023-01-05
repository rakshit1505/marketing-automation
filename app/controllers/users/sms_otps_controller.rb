# frozen_string_literal: true
class Users::SmsOtpsController < ApplicationController
    def create
      if params[:data][:attributes][:full_phone_number].present?
        account = SendOtp.find_by(full_phone_number: params[:data][:attributes][:full_phone_number], activated: true)
        return render json: {errors: [{
          account: 'Account already activated',
        }]}, status: :unprocessable_entity unless account.nil?
  
        @sms_otp = SmsOtp.new(params[:phone])  #after_create method will call
        if @sms_otp.save
          render json: { meta: { @sms_otp,
            token: BuilderJsonWebToken.encode(@sms_otp.id),
          }}.serializable_hash, status: :created
        else
          render json: {errors: format_activerecord_errors(@sms_otp.errors)},
            status: :unprocessable_entity
        end
      else
        render json: {errors: [{ phone: 'Please enter phone number' }]}, status: :unprocessable_entity
      end
    end
  
    private
  
    def format_activerecord_errors(errors)
      result = []
      errors.each do |attribute, error|
        result << { attribute => error }
      end
      result
    end
  end
  