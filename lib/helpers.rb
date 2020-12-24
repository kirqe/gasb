module Helpers
  def self.included(klass)
    klass.extend(self)
  end

  def ref_id(term)
    ref, id = term.split(":")
    [ref.to_sym, id]
  end  
end