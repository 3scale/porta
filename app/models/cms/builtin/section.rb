class CMS::Builtin::Section < CMS::Section

  self.search_type = 'section'
  self.search_origin = 'builtin'

  private

  def destroy
    Rails.logger.warn("Deleting a builtin section #{self.id} of #{provider.name}")
    super
  end

end
