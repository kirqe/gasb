class Service
  @service_classes = []

  class << self
    attr_reader :service_classes
  end

  def self.call(term, account)
    service = service_for(term, account)
    return nil unless service
    service.call
  end
  
  def self.service_for(term, account)
    service_class = Service.service_classes.find do |sc|
      sc.ref == term.to_sym
    end
    return service_class.new(term, account) if service_class
    nil
  end

  def self.inherited(klass)
    Service.service_classes << klass
  end
end

class NowService < Service
  def self.ref
    :now
  end

  def initialize(term, account, args={})
    @term = term
    @account = account
    @args = args
  end
  
  def call
    # args={metrics: 'rt:activeUsers', dimensions: 'rt:medium'}    
    metrics = 'rt:activeUsers'
    dimensions = 'rt:medium'
    @account.get_realtime_data("ga:#{@term}", metrics, dimensions: dimensions)
        .totals_for_all_results[metrics]      
  end
end

class DayService < Service
  def self.ref
    :day
  end

  def initialize(term, account, args={})
    @term = term
    @account = account
    @args = args
  end 

  def call
    metrics = 'ga:pageViews'
    @account.get_ga_data("ga:#{@term}", 'yesterday', 'today', metrics)
        .totals_for_all_results[metrics]   
  end
end

class WeekService < Service
  def self.ref
    :week
  end

  def initialize(term, account, args={})
    @term = term
    @account = account
    @args = args
  end 

  def call
    metrics = 'ga:pageViews'
    @account.get_ga_data("ga:#{@term}", '7daysAgo', 'today', metrics)
        .totals_for_all_results[metrics]    
  end
end

class MonthService < Service
  def self.ref
    :month
  end

  def initialize(term, account, args={})
    @term = term
    @account = account
    @args = args
  end 
  
  def call
    metrics = 'ga:pageViews'
    @account.get_ga_data("ga:#{@term}", '30daysAgo', 'today', metrics)
      .totals_for_all_results[metrics]  
  end
end
