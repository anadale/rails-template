class ApplicationController < ActionController::API
  include DoAndRespond
  include Pundit

  attr_reader :current_user

  before_action :authenticate!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  protected

  def authenticate!
    auth_header = request.headers['Authorization']

    unless auth_header.blank?
      token = auth_header.split(' ').last

      begin
        decoded_token = JWT.decode token, Rails.application.secrets.secret_key_base, true, algorithm: 'HS256'
      rescue JWT::ExpiredSignature
        head :unauthorized
      end

      @current_user = ServiceUser.from_jwt_payload(decoded_token[0])
    end

    head :unauthorized unless @current_user.present?
  end

  private

  def user_not_authorized
    head :forbidden
  end

  def record_not_found
    head :not_found
  end

  def record_invalid(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end
end
