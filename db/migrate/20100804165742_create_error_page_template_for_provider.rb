class CreateErrorPageTemplateForProvider < ActiveRecord::Migration
  def self.up
    if Account.find_by_id(16) && !PageTemplate.find(:first, :conditions => {:account_id => 16, :name => "error"})
      pt= PageTemplate.new(:account_id => 16, :name => "error", :handler => "liquid", :body => "<h1>{% internal_error %}</h1>")
      pt.save!
    end
  end

  def self.down
  end
end
