module Service
  module GA3
    class BaseService
      include Google::Apis::AnalyticsV3
      extend Descendable

      @@scope = 'https://www.googleapis.com/auth/analytics.readonly'

      def initialize(g_creds_key_path)
        @service = AnalyticsService.new()
        @service.request_options.retries = 3
        @service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(g_creds_key_path),
          scope: @@scope)
      end
    end

    class NowService < GA3::BaseService
      def self.labels
        [:now]
      end

      def call(term, quota_user)
        metrics = 'rt:activeUsers'
        dimensions = 'rt:medium'
        @service.get_realtime_data("ga:#{term.id}", metrics, dimensions: dimensions, quota_user: quota_user)
            .totals_for_all_results[metrics]           
      end
    end

    class DayService < GA3::BaseService
      def self.labels
        [:day]
      end

      def call(term, quota_user)
        metrics = "ga:#{term.metric}"
        @service.get_ga_data("ga:#{term.id}", 'yesterday', 'today', metrics, quota_user: quota_user)
        .totals_for_all_results[metrics]    
      end      
    end

    class WeekService < GA3::BaseService
      def self.labels
        [:week]
      end

      def call(term, quota_user)
        metrics = "ga:#{term.metric}"
        @service.get_ga_data("ga:#{term.id}", '7daysAgo', 'today', metrics, quota_user: quota_user)
            .totals_for_all_results[metrics] 
      end        
    end    

    class MonthService < GA3::BaseService
      def self.labels
        [:month]
      end

      def call(term, quota_user)
        metrics = "ga:#{term.metric}"
        @service.get_ga_data("ga:#{term.id}", '30daysAgo', 'today', metrics, quota_user: quota_user)
          .totals_for_all_results[metrics] 
      end          
    end    
  end
end