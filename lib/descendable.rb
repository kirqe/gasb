# allows to select a class from a list of subclasses based on a list of labels
# requires `labels` class method with a list of labels
#
# class Report
#   def self.labels
#     [:some_label]
#   end
# end

module Descendable
  def inherited(subclass)
    @descendants ||= []
    @descendants << subclass
  end

  def descendants
    @descendants || []
  end      

  def select(label)
    @descendants.find { |s| s.labels.include?(label) }
  end
end