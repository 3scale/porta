# frozen_string_literal: true

module ApiSupport::PrepareResponseRepresenter

  extend ActiveSupport::Concern

  included do
    include Roar::Rails::ControllerAdditions
    self.responder = ThreeScale::Api::Responder
    respond_to :xml, :json
  end

  module ClassMethods
    def representer(model)
      mimes_for_respond_to.each_key do |format|
        represents format, model
      end
    end
  end

end
