# frozen_string_literal: true

require 'will_paginate/array'

module RepresentedApiRouting

  class BaseModel
    def initialize(foo)
      @foo = foo
    end

    attr_reader :foo

    def to_xml(options)
      xml = options[:builder] || ThreeScale::XML::Builder.new
      root = self.class.name.demodulize.downcase
      xml.tag!(root) do |xml|
        xml.foo foo
      end.to_xml
    end
  end

  class Kla < BaseModel; end
  class Mod < BaseModel; end

  class KlaRepresenter < ThreeScale::Representer
    include ThreeScale::JSONRepresenter

    wraps_resource :kla

    property :foo
  end

  class KlasRepresenter < ThreeScale::CollectionRepresenter
    include ThreeScale::JSONRepresenter
    include Roar::JSON::Collection

    wraps_collection :klass

    items extend: KlaRepresenter
  end

  module ModRepresenter
    include ThreeScale::JSONRepresenter

    wraps_resource :mod

    property :foo
  end

  module ModsRepresenter
    include ThreeScale::JSONRepresenter

    wraps_collection :mods

    items extend: ModRepresenter
  end

  class BaseController < ::Admin::Api::BaseController
    paginate only: :index

    def index
      collection = params[:words].map { |foo_field| klass_model.new(foo_field) }
      respond_with collection.paginate(pagination_params)
    end

    def klass_model
      raise NoMethodError, "#{__method__} not implemented in #{self.class}"
    end
  end

  class KlasController < BaseController
    representer Kla

    def klass_model
      Kla
    end
  end

  class ModsController < BaseController
    representer Mod

    def klass_model
      Mod
    end
  end

  def with_api_routes
    Rails.application.routes.draw do
      constraints MasterOrProviderDomainConstraint do
        get '/api/klas' => 'represented_api_routing/klas#index'
        get '/api/mods' => 'represented_api_routing/mods#index'
      end

    end
    yield
  ensure
    Rails.application.routes_reloader.reload!
  end
end
