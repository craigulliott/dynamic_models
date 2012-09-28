module DynamicModelActiveRecordExtensions

  def self.included(base)
    base.extend(ClassMethods)
  end

  def sti_model?
    attribute_names.include? "type"
  end

  # for creating routes which are based on the parent class
  def sti_parent_class
    self.class.parent
  end

  module ClassMethods

    # if this class has a type attribute, then it is a model which is using single table inheritance
    def sti_model?
      attribute_names.include? "type"
    end

    # for creating routes which are based on the parent class
    def sti_parent_class
      self.parent
    end

  end
end
