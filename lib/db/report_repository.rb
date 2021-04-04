# mess...
class ReportRepository
  # def initialize(args={})
  #   @parser = args[:parser]
  # end

  def create(id)
    reportClass = representation(id)
    report = reportClass.new({term: id})
    Cache.set(id, report.to_h)
    report
  end

  def update(id, data)    
    old_data = Cache.get(id)
    new_data = old_data.merge(data)          
    Cache.set(id, new_data)

    reportClass = representation(id)
    report = reportClass.new(new_data)
    report
  end  

  def find(id)  
    report = nil
    if Cache.exists?(id)
      data = Cache.get(id)
      
      reportClass = representation(id)
      report = reportClass.new(data)        
    end
    report
  end

  def delete(id)
    Cache.delete(id)
  end

  def all(args={})
    Cache.all(args)
  end

  private
    def representation(rawTerm)
      term = Term.new(rawTerm)
      Report.select(term.label)
    end

    # # redis returns values as Strings
    # # use parser class to transform values
    # def parsed_hash(id)
    #   data = Cache.get(id)
    #   if @parser
    #     data = @parser.new(data).to_h
    #   end
    #   data
    # end
end