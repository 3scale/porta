# frozen_string_literal: true

module ResetTenantId
  extend ActiveSupport::Concern

  class Configurator
    include Singleton
    attr_reader :definitions

    def initialize
      @definitions = {}
    end

    def define(klass,  &block)
      definition = definitions[klass] ||= Definition.new(klass)
      definition.instance_exec(&block)
    end
  end

  class Definition
    attr_reader :queries, :klass
    delegate :each_value, to: :queries

    def initialize(klass)
      @klass = klass
      @queries = {}
    end

    def updates(name, options = {}, &block)
      @queries[name.to_sym] = Query.new(klass, name, options, &block)
    end

    def [](name)
      @queries[name.to_sym]
    end
  end

  class Query
    module FindEach
      def find_each(*options, &block)
        defined?(super) ? super(*options, &block) : each(&block)
      end
    end

    attr_reader :klass, :name, :update, :collection

    def initialize(klass, name, options = {}, &block)
      @klass = klass
      @name = name.to_sym
      @collection = wrap_collection(options[:collection] || @name)
      @update = wrap_update(options[:with] || block)
    end

    private

    # :nodoc:
    # Returns an object responding to #call(record)
    def wrap_update(with)
      case with
      when NilClass
        raise ArgumentError, 'Pass in `:with` option or a block'
      when Symbol
        proc do |record|
          record.update_column :tenant_id, record.public_send(with) # rubocop:disable Rails/SkipsModelValidations
        end
      else
        with
      end
    end

    # :nodoc:
    # Wraps into a proc so it can be executed in the context of the klass
    # and defer the evaluation when actually executing it
    def wrap_collection(collection)
      case collection
      when Proc
        proc { klass.instance_exec(&collection).extend(FindEach) }
      when Symbol, String
        proc { klass.public_send(collection).extend(FindEach) }
      when Enumerable
        proc { collection.tap{|object| object.extend(FindEach) } }
      else
        proc { collection.extend(FindEach) }
      end
    end
  end

  class Runner
    attr_reader :definitions

    def initialize(definitions)
      @definitions = definitions
    end

    def execute(name)
      query = find_query(name)
      execute_query(query)
    end

    def execute_all
      definitions.each_value do |query|
        execute_query(query)
      end
    end

    def find_query(name)
      definitions[name.to_sym] or raise ArgumentError, "Cannot find a query with name `#{name}`"
    end

    private

    def execute_query(query)
      query.collection.call.find_each(&query.update)
    end
  end

  def reset_tenant_id!(name)
    runner = ResetTenantId::Runner.new(ResetTenantId::Configurator.instance.definitions[self.class])
    query = runner.find_query(name)
    query.update.call(self)
  end

  module ClassMethods

    # define_reset_tenant_id do
    #   updates(:buyers, with: :provider_account_id)
    #
    #   updates(:buyers) do |record|
    #     record.provider_account_id
    #   end
    #
    #   updates(first_3_accounts, collection: Account.find(1,2,3), with: :provider_account_id)
    #
    #   updates(:all_tags, collection: -> { ActiveRecord::Base.connection.execute("SELECT id, account_id FROM tags") }) do |record|
    #     id, account_id = record
    #     ActiveRecord::Base.connection.execute("UPDATE tags SET tenant_id = account_id WHERE id = #{id}")
    #   end
    # end
    def define_reset_tenant_id(&block)
      ResetTenantId::Configurator.instance.define(self, &block)
    end

    def reset_tenant_id!(name = nil)
      runner = ResetTenantId::Runner.new(ResetTenantId::Configurator.instance.definitions[self])
      if name
        runner.execute(name)
      else
        runner.execute_all
      end
    end
  end
end
