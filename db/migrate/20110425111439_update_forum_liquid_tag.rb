class UpdateForumLiquidTag < ActiveRecord::Migration
  def self.up
    #PageTemplate.find_all_by_name('forum').each do |page|
    #  class << page
    #    def save!(perform_validations=false)
    #      save(perform_validations) || raise(ActiveRecord::RecordNotSaved.new(errors.full_messages))
    #    end
    #  end
    #
    #  page.body.gsub!(/\{\{\s*forum\s*\}\}/, "{% include \"main_layout\" %}")
    #  page.save!
    #  puts "Parsed page #{page.id}"
    #end
  end

  def self.down
  end
end
