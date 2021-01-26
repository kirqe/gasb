class Term
  attr_reader :kind, :id, :rawString, :metric
  alias :key :rawString

  def initialize(rawString)
    @rawString = rawString
    @kind, @id, @metric = rawString.split(":")
    @metric ||= "sessions"
  end

  def is_valid?
    @rawString.match?(/(now|day|week|month):([0-9]+)/)
  end

  def ref
    @kind.to_sym
  end
end