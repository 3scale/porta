class CMS::Builtin::Section < CMS::Section

  self.search_type = 'section'
  self.search_origin = 'builtin'

  has_data_tag :builtin_section

  private

  def destroy
    Rails.logger.warn("Deleting a builtin section #{self.id} of #{provider.name}")
    super
  end

end
