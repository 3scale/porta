class WebHook
  class Failure < Struct.new(:exception, :id, :url, :xml, :time)
    extend ActiveModel::Naming

    delegate :to_json, :to => :to_hash


    def initialize(exception, id, url, xml, time = Time.now)
      super(exception, id, url, xml, time)
    end

    def self.parse(string)
      return unless string

      json = JSON.parse(string)
      values = json.values_at(*%w|error id url event time|)
      new(*values)
    end

    def to_xml(options = {})
      xml = options[:builder] || ThreeScale::XML::Builder.new

      xml.tag!('webhooks-failure') do |xml|
        xml.id_ id
        xml.time time
        xml.error exception
        xml.url url
        xml << event
      end

      xml.to_xml
    end

    def event
      Nokogiri::XML.parse(xml).root.to_xml
    end

    def to_hash
      {
        :id => id, :time => time.utc,
        :error => exception.to_s,
        :url => url, :event => xml
      }
    end
  end
end
