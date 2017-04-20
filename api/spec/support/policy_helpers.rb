module PolicySupport
  module Global
    USERS = {
      administrator: {
        name: 'administrator',
        roles: ['administrator']
      },
      regular_user: {
        name: 'regular user',
        roles: []
      }
    }.freeze

    EVERYTHING = [:index, :show, :create, :update, :destroy].freeze
    VIEW_ACTIONS = [:index, :show].freeze
    CHANGE_ACTIONS = [:create, :update, :destroy].freeze
    NOTHING = [].freeze

    def service_user_name(kind)
      info = USERS[kind.to_sym]
      name = info[:name]

      %w(a e i o u).include?(name[0].downcase) ? "an #{name}" : "a #{name}"
    end
  end

  module GroupHelpers
    def policy_checker_of(*record_type_and_options)
      let(:record) { create(*record_type_and_options) }
      subject { described_class.new(user, record) }

      yield if block_given?
    end

    def check_policy_for(kind, allow: :everything, forbid: :nothing)
      allow = normalize_actions allow
      forbid = normalize_actions forbid

      context "Being #{service_user_name(kind)}" do
        let(:user) { create_service_user(kind) }

        allow.each do |action|
          it "allows user to call #{action}" do
            is_expected.to permit_action(action)
          end
        end

        forbid.each do |action|
          it "forbids user to call #{action}" do
            is_expected.to forbid_action(action)
          end
        end
      end
    end

    def normalize_actions(actions)
      case actions
      when :everything
        PolicySupport::Global::EVERYTHING
      when :view
        PolicySupport::Global::VIEW_ACTIONS
      when :change
        PolicySupport::Global::CHANGE_ACTIONS
      when :nothing
        PolicySupport::Global::NOTHING
      else
        actions
      end
    end
  end

  module ExampleHelpers
    def create_service_user(kind)
      info = PolicySupport::Global::USERS[kind.to_sym]

      ServiceUser.new 1, 'user', info[:name], info[:roles], email: Faker::Internet.email(info[:name])
    end
  end
end
