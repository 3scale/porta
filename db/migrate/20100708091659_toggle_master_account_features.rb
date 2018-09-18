class ToggleMasterAccountFeatures < ActiveRecord::Migration

  def self.up

    # Forum
    if feature_1316 = Feature.find_by_id(1316)
      feature_1316.update_attribute(:visible, true)
    end

    # Application Gallery
    if feature_1326 = Feature.find_by_id(1326)
      feature_1326.update_attribute(:visible, true)
    end

  end

  def self.down
    # 
  end

end
