class ServiceUser
  attr_reader :id, :name, :email, :roles

  def initialize(id, name, email, roles)
    @id = id
    @name = name
    @email = email
    @roles = roles.flatten.uniq.map(&:to_s).map(&:downcase)
  end

  def self.from_jwt_payload(payload)
    new payload['id'].to_i, payload['name'], payload['email'], payload['roles']
  end

  def to_jwt_payload(extra_data = {})
    {
      id: @id,
      name: @name,
      email: @email,
      roles: @roles
    }.merge(extra_data)
  end

  def in_role?(role)
    @roles.include? normalize_role(role)
  end

  def in_any_role?(*roles)
    (normalize_roles(roles) & @roles).any?
  end

  def in_all_roles?(*roles)
    (normalize_roles(roles) - @roles).empty?
  end

  private

  def normalize_role(role)
    role.to_s.downcase.dasherize
  end

  def normalize_roles(roles)
    roles.map(&:to_s).map(&:downcase).map(&:dasherize)
  end
end
