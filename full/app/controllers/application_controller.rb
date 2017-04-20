class ApplicationController < ActionController::Base
  include DoAndRespond
  include Pundit

  protect_from_forgery with: :exception

  after_action :prepare_unobtrusive_flash

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = 'Извините, но у Вас нет прав на выполнение данной операции :-('

    redirect_to(request.referrer || root_path)
  end
end
