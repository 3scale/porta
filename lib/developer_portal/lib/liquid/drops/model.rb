module Liquid
  module Drops
    class Model < Drops::Base

      def initialize(model)
        @model = model
        super()
      end

      desc %{
        If a form for this model is rendered after unsuccessful submission,
        this returns the errors that occurred.}

      example %{
            <input name="<model>[name]"
                   value="{{ <model>.name }}"
                   class="{{ <model>.errors.name | error_class }}"/>
            {{ <model>.errors.name | inline_errors }}
      }
      def errors
        Drops::Errors.new(@model)
      end

      delegate :hash, to: :@model

      # implementing these two allows us to use
      # model instances as hash keys
      def ==(other)
        self.class === other &&
          @model == other.instance_variable_get(:@model)
      end

      alias eql? ==

      hidden
      def to_param
        @model.id
      end
    end
  end
end
