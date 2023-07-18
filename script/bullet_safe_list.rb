#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require "optparse"
require "yaml"

class BulletSafeList
  class << self
    def parse_cli_opts
      options = {}

      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: #{$PROGRAM_NAME} bullet.log [bullet_1.log ...] [options]"
        opts.on("-h", "--help", "Prints this help") do
          warn opts
          exit
        end
      end

      optparse.parse!

      options[:files] = ARGV

      raise OptionParser::MissingArgument, "bullet.log" if options[:files].empty?

      options
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument
      warn $ERROR_INFO.to_s
      warn optparse
      abort
    end
  end

  def initialize(files:)
    @files = files.freeze
  end

  def generate
    offences = files.map { |file| parse_bullets(file) }.flatten

    puts offences.map(&:to_safelist).sort.uniq
  end

  private

  attr_reader :files

  def parse_bullets(file)
    File.open(file, mode: "r") do |f|
      f.each_line.slice_when { |before, _after| before.chomp.empty? }.map do |lines|
        Offence.parse(lines.join)
      end
    end
  end

  class Offence
    class << self
      def parse(str)
        lines = str.lines
        method, path = lines[1].split(" ", 2)
        type = parse_type(lines[2])
        class_name, associations = lines[3].split(" => ", 2)
        associations = parse_associations(associations)
        new(method: method, path: path.chomp, text: str, class_name: class_name.strip, type: type, associations: associations)
      end

      private

      def parse_type(line)
        case line
        when /^AVOID eager/
          :unused_eager_loading
        when /^USE eager/
          :n_plus_one_query
        when /^Need Counter Cache/
          :counter_cache
        else
          raise "unknown type line: #{line}"
        end
      end

      def parse_associations(associations)
        associations.strip[1...-1].split(/,\s*/).map { |str| str[1..-1] }.map(&:to_sym)
      end
    end

    attr_accessor :associations, :class_name, :method, :path, :text, :type

    def initialize(method:, path:, text:, type:, class_name:, associations:)
      @method = method.freeze
      @path = path.freeze
      @type = type.freeze
      @class_name = class_name.freeze
      @associations = associations.freeze
      @text = text.freeze
    end

    alias to_s text

    def to_safelist
      associations.map do |association|
        %(Bullet.add_safelist class_name: "#{class_name}", type: :#{type}, association: :#{association})
      end
    end
  end
end

if $0 == __FILE__ # rubocop:disable Style/SpecialGlobalVars,Style/IfUnlessModifier
  BulletSafeList.new(**BulletSafeList.parse_cli_opts).generate
end
