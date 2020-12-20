class Service
  include Helpers
  @service_classes = []

  class << self
    attr_reader :service_classes
  end

  def self.inherited(klass)
    Service.service_classes << klass
  end
  
  def self.service_for(term, account)
    ref = ref_id(term).first
    service_class = Service.service_classes.find do |sc|
      sc.ref == ref
    end

    return service_class.new(term, account) if service_class
    nil
  end

  # 
  def self.call(term, account)
    service = service_for(term, account)
    return nil unless service
    service.call
  end

  def initialize(term, account, args={})
    @ref, @id = ref_id(term)
    @service = account.service
    @args = args
  end
end

class NowService < Service
  def self.ref
    :now
  end

  def initialize(term, account, args={})
    super(term, account, args={})
  end
  
  def call
    # args={metrics: 'rt:activeUsers', dimensions: 'rt:medium'} 
    metrics = 'rt:activeUsers'
    dimensions = 'rt:medium'
    @service.get_realtime_data("ga:#{@id}", metrics, dimensions: dimensions)
        .totals_for_all_results[metrics]      
  end
end

class DayService < Service
  def self.ref
    :day
  end

  def initialize(term, account, args={})
    super(term, account, args={})
  end
  
  def call
    metrics = 'ga:pageViews'
    @service.get_ga_data("ga:#{@id}", 'yesterday', 'today', metrics)
        .totals_for_all_results[metrics]   
  end
end

class WeekService < Service
  def self.ref
    :week
  end

  def initialize(term, account, args={})
    super(term, account, args={})
  end

  def call
    metrics = 'ga:pageViews'
    @service.get_ga_data("ga:#{@id}", '7daysAgo', 'today', metrics)
        .totals_for_all_results[metrics]    
  end
end

class MonthService < Service
  def self.ref
    :month
  end

  def initialize(term, account, args={})
    super(term, account, args={})
  end
  
  def call
    metrics = 'ga:pageViews'
    @service.get_ga_data("ga:#{@id}", '30daysAgo', 'today', metrics)
      .totals_for_all_results[metrics]    
  end
end
