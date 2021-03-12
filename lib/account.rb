
class Account
  include Google::Apis::AnalyticsV3

  attr_reader :service
  
  @@scope = 'https://www.googleapis.com/auth/analytics.readonly'

  def initialize(service_account_data)
    @service = AnalyticsService.new()
    @service.request_options.retries = 3
    @service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(service_account_data),
      scope: @@scope)
  end
end


# class Account
#   include Google::Apis::AnalyticsV3

#   attr_reader :service
  
#   def initialize(email)
#     @service = account(email)
#   end

#   private
#     def account(email)
#       keys = Dir["./keys/*.json"]

#       key = keys.find { |k| k.match(/keys\/(.*).json/,1)[1] == email }

#       if key 
#         service = AnalyticsService.new()
#         # service.client_options.send_timeout_sec = 1200
#         # service.client_options.open_timeout_sec = 1200
#         service.request_options.retries = 0
#         service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
#         json_key_io: File.open(key),
#         scope: 'https://www.googleapis.com/auth/analytics.readonly')
        
#         return service
#       end

#       nil
#     end  
# end