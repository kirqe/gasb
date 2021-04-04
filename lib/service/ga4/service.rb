module Service
  module GA4
    class BaseService
      include Google::Apis::AnalyticsdataV1beta
      extend Descendable

      @@scope = 'https://www.googleapis.com/auth/analytics.readonly'

      def initialize(g_creds_key_path)
        @service = AnalyticsDataService.new()
        @service.request_options.retries = 3
        @service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(g_creds_key_path),
          scope: @@scope)
      end
    end

    class NowService < GA4::BaseService
      def self.labels
        [:now]
      end

      def call(term, quota_user)
        metrics = "activeUsers"
        @service.run_property_realtime_report("properties/#{term.id}",
          RunRealtimeReportRequest.new(
            dimensions: [
              Dimension.new(name: "country")
            ], 
            metrics: [
              Metric.new(name: metrics)
            ],
            quota_user: quota_user      
          )
        )               
      end
    end

    class DayService < GA4::BaseService
      def self.labels
        [:day]
      end

      def call(term, quota_user)
        @service.run_property_report("properties/#{term.id}",
          RunReportRequest.new(
            dimensions: [
              Dimension.new(name: "country")
            ], 
            metrics: [
              Metric.new(name: term.metric)
            ],
            date_ranges: [
              DateRange.new(start_date: '1daysAgo', end_date: 'today')
            ],
            quota_user: quota_user           
          )
        )         
      end      
    end

    class WeekService < GA4::BaseService
      def self.labels
        [:week]
      end

      def call(term, quota_user)
        @service.run_property_report("properties/#{term.id}",
          RunReportRequest.new(
            dimensions: [
              Dimension.new(name: "country")
            ], 
            metrics: [
              Metric.new(name: term.metric)
            ],
            date_ranges: [
              DateRange.new(start_date: '7daysAgo', end_date: 'today')
            ],
            quota_user: quota_user           
          )
        )
      end        
    end    

    class MonthService < GA4::BaseService
      def self.labels
        [:month]
      end

      def call(term, quota_user)
        @service.run_property_report("properties/#{term.id}",
          RunReportRequest.new(
            dimensions: [
              Dimension.new(name: "country")
            ], 
            metrics: [
              Metric.new(name: term.metric)
            ],
            date_ranges: [
              DateRange.new(start_date: '30daysAgo', end_date: 'today')
            ],
            quota_user: quota_user           
          )
        )                
      end          
    end  
  end
end