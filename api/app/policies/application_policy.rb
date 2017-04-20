class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    allow?
  end

  def update?
    allow?
  end

  def destroy?
    allow?
  end

  def allow?
    user.in_role? :administrator
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  def permitted_attributes_for_create
    self.class.permitted_attributes :create
  end

  def permitted_attributes_for_update
    self.class.permitted_attributes :update
  end

  def self.permitted_attributes(scope)
    @permitted_attributes ||= {}

    scoped = @permitted_attributes[scope]

    unless scoped
      scoped = []
      @permitted_attributes[scope] = scoped
    end

    scoped
  end

  #
  # permit_attributes :name, :description, except: :create
  # permit_attribute :name, :description, only: :create

  KNOWN_SCOPES = %i(create update).freeze

  def self.permit_attributes(*attributes)
    options = attributes.extract_options!
    except = options.delete :except
    only = options.delete :only

    if only.present?
      only = [only] unless only.is_a? Array
      scopes = only.select { |item| KNOWN_SCOPES.include? item }
    elsif except.present?
      except = [except] unless except.is_a? Array
      scopes = KNOWN_SCOPES - except
    else
      scopes = KNOWN_SCOPES
    end

    scopes.each do |scope|
      scoped = permitted_attributes(scope)

      scoped.concat(attributes)
      scoped.push(options) if options.any?
    end
  end
end
