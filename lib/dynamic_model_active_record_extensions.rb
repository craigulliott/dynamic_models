module DynamicModelActiveRecordExtensions

  def self.included(base)
    base.extend(ClassMethods)
  end

  def sti_model?
    return false if sti_parent_class == ActiveRecord::Base
    attribute_names.include? "type"
  end

  # for creating routes which are based on the parent class
  def sti_parent_class
    self.class.superclass
  end

  module ClassMethods

    # if this class has a type attribute, then it is a model which is using single table inheritance
    # if it is the base class for STI, its parent will be ActiveRecord::Base -- if using AR.
    def sti_model?
      return false if sti_parent_class == ActiveRecord::Base
      attribute_names.include? "type"
    end

    # for creating routes which are based on the parent class
    def sti_parent_class
      self.superclass
    end

  end
end
