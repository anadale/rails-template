class ApplicationResource < JSONAPI::Resource
  include JSONAPI::Authorization::PunditScopedResource

  abstract

  def current_user
    context[:current_user]
  end
end
