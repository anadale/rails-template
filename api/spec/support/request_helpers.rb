module RequestSupport
  module Global
    def authorize_as_admin(*extra_roles)
      authorize(['administrator'] + extra_roles)
    end

    def authorize(*roles)
      @service_user = ServiceUser.new(1, 'User', 'Test User', roles)
    end
  end

  module GroupHelpers
  end

  module ExampleHelpers
    def json
      @json ||= JSON.parse(response.body, symbolize_names: true)
    end

    %i(get post put delete).each do |verb|
      define_method("api_#{verb}".to_sym) do |path, params = {}|
        headers = {}

        if @service_user.present?
          payload = @service_user.to_jwt_payload(exp: (Time.now + 20.minutes).to_i)
          token = JWT.encode payload, Rails.application.secrets.auth_secret, 'HS256'

          headers[:Authorization] = "Bearer #{token}"
        end

        headers['Content-Type'] = 'application/vnd.api+json'

        params = params.to_json

        send verb, path, params: params, headers: headers

        response
      end
    end
  end
end
