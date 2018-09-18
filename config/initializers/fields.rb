# Load some association extensions to allow creating objects with fields through association
Rails.logger.debug 'Initializing Fields AssociationCollection extensions'
ActiveRecord::Associations::CollectionProxy.send :include, Fields::Extensions::AssociationCollectionExtension
ActiveRecord::Relation.send :include, Fields::Extensions::AssociationCollectionExtension
