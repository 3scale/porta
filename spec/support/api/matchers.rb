RSpec::Matchers.define :have_properties do |*properties|

  chain :from do | resource |
    @resource = resource
  end

  def diffable?
    true
  end

  def match_actual_with_expected
    @expected.all? do |key, value|
      @actual && @actual.has_key?(key) && @actual[key] == value
    end
  end

  match do |json|

    @actual = json

    if properties.one?{|p| p.is_a?(Hash) }
      @expected = properties.first.stringify_keys

      match_actual_with_expected
    else
      properties = properties.flatten.map(&:to_s)

      if @resource
        pairs = properties.map do |property|
          [ @resource.send(property).try!(:as_json), @actual && @actual[property] ]
        end

        expected, actual = pairs.transpose

        @expected = Hash[ properties.zip(expected) ]

        match_actual_with_expected

      else
        @expected = properties

        properties.all? { |key| @actual.has_key?(key) }
      end
    end
  end
end

RSpec::Matchers.define :have_links do |*expected|
  match do |json|
    links = json && json['links']
    next unless links.present?

    @actual = links.map{|l| l['rel'] }.sort
    @expected = expected.flatten.sort

    @actual == @expected
  end
end

RSpec::Matchers.define :have_tags do |*properties|
  chain :from do | resource |
    @resource = resource
  end

  match do |xml|
    if @resource
      properties.flatten.all? do |property|
        expected = @resource.public_send(property)
        expected = expected.try(:iso8601) || expected.to_s
        actual = xml.xpath(".//#{property}").first&.text
        expected == actual
      end
    end
  end
end
