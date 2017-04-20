RSpec::Matchers.define :have_http_header do |header_name|
  match do |response|
    @header_name = header_name
    @header = response.headers[header_name]

    return false unless @header.present?
    return true unless @matcher.present?

    @matcher.matches? @header
  end

  chain :that_eq do |value|
    @matcher = RSpec::Matchers::BuiltIn::Eq.new(value)
  end

  chain :that_matches do |value|
    @matcher = RSpec::Matchers::BuiltIn::Match.new(value)
  end

  chain :that_start_with do |value|
    @matcher = RSpec::Matchers::BuiltIn::StartWith.new(value)
  end

  failure_message do |_|
    return "expected the response to have header #{@header_name}, but got none." unless @header.present?

    "incorrect value of header #{@header_name}, #{@matcher.failure_message}"
  end
end
