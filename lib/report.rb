class Report
  attr_reader :term, :ref, :id
  attr_accessor :update_interval, :service, :value, :updated_at, :queued

  @refs = []

  class << self
    attr_reader :refs
  end

  def self.inherited(klass)
    Report.refs << klass
  end

  def self.new_as(term, args={})
    report = Report.refs.find {|r| r.refs.include?(args[:as]) }

    return report.new(term, args) if report
    nil
  end

  def initialize(term, args={})
    @term = term
    @value = args[:value] || 0
    @updated_at = args[:updated_at] || (Time.now - (60 * 60 * 24))
    @update_interval ||= 30 * 60
    @queued = (args[:queued] == "true" ? true : false) || false
  end

  def can_be_updated? #stale?
    (Time.now > (@updated_at + @update_interval)) && !queued
  end

  def to_h
    {
      term: @term,
      value: @value,
      updated_at: @updated_at,
      queued: @queued
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