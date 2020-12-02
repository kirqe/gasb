class Report
  attr_reader :term, :kind, :id
  attr_accessor :update_interval, :service, :value, :updated_at

  def initialize(term, args={})
    @term = term
    @kind, @id = @term.split(":")
    @value = args[:value] || 0
    @updated_at = args[:updated_at] || Time.now
    @update_interval = 30# * 60
  end

  def can_be_updated? #stale?
    Time.now > (@updated_at + @update_interval) # 30 sec
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

class RealTimeReport < Report
  def initialize()
    super
    @update_interval = 30
  end
end