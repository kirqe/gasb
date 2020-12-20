class Account
  include Google::Apis::AnalyticsV3

  attr_reader :service
  
  def initialize(email)
    @service = account(email)
  end

  private
    def account(email)
      keys = Dir["./keys/*.json"]

      key = keys.find { |k| k.match(/keys\/(.*).json/,1)[1] == email }

      if key 
        service = AnalyticsService.new()
        service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(key),
        scope: 'https://www.googleapis.com/auth/analytics.readonly')
        
        return service
      end

      nil
    end  
end