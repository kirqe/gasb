class Report
  include Helpers

  attr_reader :term, :ref, :id
  attr_accessor :update_interval, :service, :value, :updated_at

  @report_refs = []

  class << self
    attr_reader :report_refs
  end

  def self.inherited(klass)
    Report.report_refs << klass
  end

  def self.new_of_ref(term, args={})
    ref = ref_id(term).first
    report = Report.report_refs.find {|r| r.refs.include?(ref) }

    return report.new(term, args) if report
    nil
  end

  def initialize(term, args={})
    @term = term
    @value = args[:value] || 0
    @updated_at = args[:updated_at] || Time.now
    @update_interval ||= 30 * 60
  end

  def can_be_updated? #stale?
    Time.now > (@updated_at + @update_interval)
  end

  def to_h
    {
      term: @term,
      value: @value,
      updated_at: @updated_at
    }
  end

  def to_json
    to_h.to_json
  end
end

class PlainReport < Report
  attr_accessor :update_interval

  def self.refs
    [:day, :week, :month]
  end

  def initialize(term, args={})
    super(term, args)
    @update_interval = 15 * 60 # 15 minutes
  end
end

class RealTimeReport < Report
  attr_accessor :update_interval

  def self.refs
    [:now]
  end

  def initialize(term, args={})
    super(term, args)
    @update_interval = 30 # 30 seconds
  end
end