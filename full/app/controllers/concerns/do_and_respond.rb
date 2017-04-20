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
  #		+error_action:+ Action to render in case of error, default is +new+.
  #		+variable:+ Name of the instance variable to set, default is inflected from class name.
  #		+html:+ Whether to respond to HTML format, default is +true+.
  #		+json:+ Whether to respond to JSON format, default is +true+.
  def create_and_respond(klass, *args)
    options = args.extract_options!
    params = parameters(klass, args.first, :new, options) || return

    object = params.present? ? klass.new(params) : klass.new

    yield object if block_given?

    variable_name = options.fetch(:variable, klass.name.underscore)

    instance_variable_set "@#{variable_name}".to_sym, object if variable_name

    authorize(object) if options.fetch(:authorize, true)

    respond_to_html = options.fetch(:html, true)
    respond_to_json = options.fetch(:json, true)

    respond_to do |format|
      if object.save
        path = build_path(object, options)

        format.html { redirect_to path } if respond_to_html
        format.json { head :created, location: path } if respond_to_json
      else
        format.html { render options.fetch(:error_action, :new) } if respond_to_html
        format.json { render json: object.errors.full_messages, status: :unprocessable_entity } if respond_to_json
      end
    end

    object
  end

  # Updates +object+ with +params+ and responds in several formats afterwards.
  #
  # +options+ are:
  #		+path:+ Path to redirect in case of success, default is +show+ action for +object+.
  #		+error_action:+ Action to render in case of error, default is +new+.
  #		+html:+ Whether to respond to HTML format, default is +true+.
  #		+json:+ Whether to respond to JSON format, default is +true+.
  def update_and_respond(object, *args)
    options = args.extract_options!
    params = parameters(object.class, args.first, :edit, options) || return

    authorize(object) if options.fetch(:authorize, true)

    respond_to_html = options.fetch(:html, true)
    respond_to_json = options.fetch(:json, true)

    respond_to do |format|
      if object.update(params)
        format.html { redirect_to build_path(object, options) } if respond_to_html
        format.json { head :ok } if respond_to_json
      else
        format.html { render action: options.fetch(:error_action, :edit) } if respond_to_html
        format.json { render json: object.errors.full_messages, status: :unprocessable_entity } if respond_to_json
      end
    end
  end

  # Destroys +object+ and responds in several formats afterwards.
  #
  # +options+ are:
  #		+notice:+ Notice text, defaults to 'XXX has been deleted.'
  #		+path:+ Path to redirect in case of success, default is +show+ action for +object+.
  #		+error_action:+ Action to render in case of error, default is +new+.
  #		+html:+ Whether to respond to HTML format, default is +true+.
  #		+json:+ Whether to respond to JSON format, default is +true+.
  def destroy_and_respond(object, options = {})
    notice = options.fetch(
      :notice,
      t(
        "d_a_r.destroy.#{object.class.name}",
        default: 'd_a_r.destroy.default',
        model: object.class.name.humanize
      )
    )

    authorize(object) if options.fetch(:authorize, true)

    result = object.destroy

    respond_to_html = options.fetch(:html, true)
    respond_to_json = options.fetch(:json, true)

    respond_to do |format|
      if result
        format.html { redirect_to build_path(object.class, options), notice: notice } if respond_to_html
        format.json { head :ok } if respond_to_json
      else
        format.html { render action: options.fetch(:error_action, :show) } if respond_to_html
        format.json { render json: object.errors.full_messages, status: :unprocessable_entity } if respond_to_json
      end
    end
  end

  def push_path_element(element)
    @path_elements ||= []

    @path_elements << element

    element
  end

  private

  def parameters(klass, params, default_error_action, options)
    if params.nil? && options.fetch(:policy_params, true)
      begin
        params = permitted_attributes(klass)
      rescue ActionController::ParameterMissing => err
        respond_to_html = options.fetch(:html, true)
        respond_to_json = options.fetch(:json, true)
        respond_to_js = options.fetch(:js, false)

        respond_to do |format|
          format.html { render options.fetch(:error_action, default_error_action) } if respond_to_html
          format.json { render json: { error: err.message }, status: :unprocessable_entity } if respond_to_json
          format.js if respond_to_js
        end

        skip_authorization if options.fetch(:authorize, true)

        return nil
      end
    end

    params
  end

  def build_path(object, options)
    path = options[:path]

    if path.nil? or path.is_a? Symbol
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
