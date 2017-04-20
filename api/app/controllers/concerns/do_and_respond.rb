module DoAndRespond
  extend ActiveSupport::Concern

  # Creates, initializes and saves model of specified +klass+ with responding in
  # several formats afterwards.
  #
  # There are several ways to call +create_and_respond+:
  #
  #		create_and_respond +klass+, +params+
  #		create_and_respond +klass+, +params+, +options+
  #		create_and_respond +klass+, +options+ do ... end
  #
  # If +params+ array is provided then it is passed as a constructor argument to +klass+.new call
  #
  # If +block+ is given then it is called right after model instance initialization. New instance
  # is passed to the +block+ as an argument.
  #
  # +options+ are:
  #		+path:+ Path to redirect in case of success, default is +show+ action for +klass+.
  #		+variable:+ Name of the instance variable to set, default is inflected from class name.
  def create_and_respond(klass, params = nil, options = {})
    params = parameters(klass, params, options) || return
    object = params ? klass.new(params) : klass.new

    yield object if block_given?

    variable_name = options.fetch(:variable, klass.name.underscore)

    instance_variable_set "@#{variable_name}".to_sym, object if variable_name

    authorize(object) if options.fetch(:authorize, true)

    if object.save
      head :created, location: build_path(object, options)
    else
      render json: object.errors.full_messages, status: :unprocessable_entity
    end

    object
  end

  # Updates +object+ with +params+ and responds in several formats afterwards.
  #
  # +options+ are:
  #		+path:+ Path to redirect in case of success, default is +show+ action for +object+.
  #		+error_action:+ Action to render in case of error, default is +new+.
  def update_and_respond(object, params = nil, options = {})
    params = parameters(object.class, params, options) || return

    authorize(object) if options.fetch(:authorize, true)

    if object.update(params)
      head :no_content
    else
      render json: object.errors.full_messages, status: :unprocessable_entity
    end
  end

  # Destroys +object+ and responds in several formats afterwards.
  #
  # +options+ are:
  #		+path:+ Path to redirect in case of success, default is +show+ action for +object+.
  #		+error_action:+ Action to render in case of error, default is +new+.
  def destroy_and_respond(object, options = {})
    authorize(object) if options.fetch(:authorize, true)

    result = object.destroy

    if result
      head :ok
    else
      render json: object.errors.full_messages, status: :unprocessable_entity
    end

    result
  end

  def push_path_element(element)
    @path_elements ||= []

    @path_elements << element

    element
  end

  private

  def parameters(klass, params, options)
    if params.nil? && options.fetch(:policy_params, true)
      begin
        params = permitted_attributes(klass)
      rescue ActionController::ParameterMissing => err
        render json: { error: err.message }, status: :unprocessable_entity
      end

      skip_authorization if options.fetch(:authorize, true)
    end

    params
  end

  def build_path(object, options)
    path = options[:path]

    if path.nil? || path.is_a?(Symbol)
      fqcn = self.class.name.split('::')
      fqcn.pop

      action = nil

      if path.is_a? Symbol
        if path == :index
          object = object.class
        else
          action = path
        end
      end

      if fqcn.length > 0
        fqcn = fqcn.map(&:downcase).map(&:to_sym)

        fqcn += @path_elements.flatten unless @path_elements.nil?
        fqcn << object

        path = polymorphic_path(fqcn, action: action)
      else
        path = polymorphic_path(object, action: action)
      end
    elsif path.respond_to? :call
      path = path.call object
    elsif path.is_a? ApplicationRecord
      path = polymorphic_path(path)
    elsif path.is_a? Array
      path = polymorphic_path(path + [object])
    else
      path = path.to_s
    end

    path
  end

end
