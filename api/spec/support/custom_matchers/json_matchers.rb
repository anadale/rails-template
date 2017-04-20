RSpec::Matchers.define :match_json do |expected|
  match do |actual|
    json = JSON.parse(actual.body, symbolize_names: true)

    @matcher = RSpec::Matchers::BuiltIn::Match.new(expected)
    @matcher.matches? json
  end

  failure_message do
    @matcher.failure_message
  end

  failure_message_when_negated do
    @matcher.failure_message_when_negated
  end
end

RSpec::Matchers.define :match_json_schema_in_file do |schema|
  match do |response|
    schema_directory = "#{Dir.pwd}/spec/schemas"
    schema_path = "#{schema_directory}/#{schema}.json"

    JSON::Validator.validate!(schema_path, response.body, strict: true)
  end
end

RSpec::Matchers.define :match_json_schema do |schema|
  match do |response|
    JSON::Validator.validate!(schema, response.body, strict: true)
  end
end
