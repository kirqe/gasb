
class Service
  attr_reader :id, :service

  def initialize(id, service, args={})
    @id = id
    @service = service
  end
end

class NowService < Service
  include ServiceRegistry

  def initialize(id, service, args={})
    super(id, service, args)
  end
  
  def call
    # args={metrics: 'rt:activeUsers', dimensions: 'rt:medium'}    
    metrics = 'rt:activeUsers'
    dimensions = 'rt:medium'
    @service.get_realtime_data("ga:#{@id}", metrics, dimensions: dimensions)
        .totals_for_all_results[metrics]      
  end

  def self.ref
    :now
  end
end

class DayService < Service
  include ServiceRegistry

  def initialize(id, service, args={})
    super(id, service, args)
  end    

  def call
    metrics = 'ga:pageViews'
    @service.get_ga_data("ga:#{@id}", 'yesterday', 'today', metrics)
        .totals_for_all_results[metrics]   
  end

  def self.ref
    :day
  end
end

class WeekService < Service
  include ServiceRegistry
  
  def initialize(id, service, args={})
    super(id, service, args)
  end

  def call
    metrics = 'ga:pageViews'
    @service.get_ga_data("ga:#{@id}", '7daysAgo', 'today', metrics)
        .totals_for_all_results[metrics]    
  end

  def self.ref
    :week
  end
end

class MonthService < Service
  include ServiceRegistry

  def initialize(id, service, args={})
    super(id, service, args)
  end  
  
  def call
    metrics = 'ga:pageViews'
    @service.get_ga_data("ga:#{@id}", '30daysAgo', 'today', metrics)
      .totals_for_all_results[metrics]  
  end

  def self.ref
    :month
  end
end

