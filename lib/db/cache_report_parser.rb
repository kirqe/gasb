# used to transform string values from redis
# to the values that we actually need
class CacheReportParser
  def initialize(args={})
    @term = args[:term]
    @value = args[:value].to_i
    @updated_at = Time.parse(args[:updated_at])
    @queued = args[:queued]
  end

  def to_h
    {
      term: @term,
      value: @value,
      updated_at: @updated_at,
      queued: @queued
    }
  end
end