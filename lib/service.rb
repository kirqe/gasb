class Service
  @service_classes = []

  class << self
    attr_reader :service_classes
  end

  def self.inherited(klass)
    Service.service_classes << klass
  end
  
  def self.service_for(term, account, quota_user)
    service_class = Service.service_classes.find { |sc| sc.ref == term.ref }

    return service_class.new(term, account, quota_user) if service_class
    nil
  end

  def self.call(term, account, quota_user)
    service = service_for(term, account, quota_user)
    return nil unless service

    # https://developers.google.com/analytics/devguides/config/mgmt/v3/errors#backoff  
    value = 0
    for n in (0..5)      
      begin
        value = service.call
        # p "--A: #{n}, --S: #{service}, --V: #{value}"
        return value
      rescue Google::Apis::RateLimitError => e
        p "--RateError: #{e}"
        sleep((2 ** n) + rand)
      rescue => e
        p "--GenericError: #{e}"
        break
      end
    end
    value
  end

  def initialize(term, account, quota_user, args={})
    @term = term
    @service = account.service
    @quota_user = quota_user
    @args = args
    @metric = "ga:#{term.metric}"
  end
end

class NowService < Service
  def self.ref
    :now
  end

  def call
    metrics = 'rt:activeUsers'
    dimensions = 'rt:medium'
    @service.get_realtime_data("ga:#{@term.id}", metrics, dimensions: dimensions, quota_user: @quota_user)
        .totals_for_all_results[metrics]      
  end
end

class DayService < Service
  def self.ref
    :day
  end
  
  def call
    @service.get_ga_data("ga:#{@term.id}", 'yesterday', 'today', @metric, quota_user: @quota_user)
        .totals_for_all_results[@metric]   
  end
end

class WeekService < Service
  def self.ref
    :week
  end

  def call
    @service.get_ga_data("ga:#{@term.id}", '7daysAgo', 'today', @metric, quota_user: @quota_user)
        .totals_for_all_results[@metric]    
  end
end

class MonthService < Service
  def self.ref
    :month
  end

  def call
    @service.get_ga_data("ga:#{@term.id}", '30daysAgo', 'today', @metric, quota_user: @quota_user)
      .totals_for_all_results[@metric]    
  end
end
