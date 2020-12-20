# https://guides.hanamirb.org/repositories/overview/
class ReportRepository
  def initialize(args={})
    @parser = args[:parser]
  end

  def create(id)
    report = Report.new(id)
    Cache.set(id, report.to_h)
    report
  end

  def update(id, data)   
    old_data = parsed_hash(id)
    new_data = old_data.merge(data)        
    Cache.set(id, new_data)
    Report.new(id, new_data)
  end  

  def find(id)
    report = nil
    if Cache.exists?(id)
      data = parsed_hash(id)
      report = Report.new(id, data)
    end
    report
  end  

  def find_of_ref(id)
    report = nil
    if Cache.exists?(id)
      data = parsed_hash(id)
      report = Report.new_of_ref(id, data)
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
    # redis returns values as Strings
    # use parser class to transform values
    def parsed_hash(id)
      data = Cache.get(id)
      if @parser
        data = @parser.new(data).to_h
      end
      data
    end
end