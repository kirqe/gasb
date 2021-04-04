class Report
  extend Descendable
  attr_reader :term
  attr_accessor :update_interval, :value, :updated_at, :queued

  def initialize(args={})
    @term = args[:term]
    @value = args[:value].to_i || 0
    @updated_at = args[:updated_at] || "#{(Time.now - (60 * 60 * 24))}"
    @update_interval = 30 * 60
    @queued = true?(args[:queued])
  end

  def can_be_updated? #stale?
    # v = @updated_at.is_a?(Time) ? @updated_at : Time.parse(@updated_at)
    (Time.now > (Time.parse(@updated_at) + @update_interval)) && !@queued
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

  private
    def true?(boolStr)
      boolStr == "true"
    end
end

class PlainReport < Report
  def self.labels
    [:day, :week, :month]
  end

  def initialize(args={})
    super(args)
    @update_interval = 15 * 60 # 15 minutes
  end
end

class RealTimeReport < Report
  def self.labels
    [:now]
  end

  def initialize(args={})
    super(args)
    @update_interval = 30 # 30 seconds
  end
end