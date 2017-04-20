class ResourceController < ApplicationController
  include JSONAPI::ActsAsResourceController

  private

  def context
    { current_user: current_user }
  end
end
