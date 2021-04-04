# now:view:193451539:sessions
# @label  = now
# @kind   = view
# @id     = 193451539
# @metric = sessions

class Term
  attr_reader :kind, :id, :rawString, :metric
  alias :key :rawString

  def initialize(rawString)
    @rawString = rawString
    @label, @kind, @id, @metric = rawString.split(":")
    @metric ||= "sessions"
  end

  def is_valid?
    @rawString.match?(/(now|day|week|month):(view|property):([0-9]+)/)
  end

  def label
    @label.to_sym
  end
end