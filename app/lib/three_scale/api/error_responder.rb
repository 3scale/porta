class ThreeScale::Api::ErrorResponder < ThreeScale::Api::Responder

  def to_format
    resource = self.resource
    resource = representer.prepare(resource) unless resource.frozen?

    controller.render format => resource, status: :unprocessable_entity
  end

  def representer
    super.format(format)
  end
end
