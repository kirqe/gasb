module ServiceAccounts
  @instances = []

  class << self
    attr_reader :instances
  end

  def self.included(base)
    keys = Dir["./keys/*.json"]
    keys.each do |k|
      @instances << BaseService.new(k)
    end
  end

  def self.select_account(client_email)
    @instances.find { |s| s.client_email == client_email }
      .service
  end

  class BaseService
    include Google::Apis::AnalyticsV3

    attr_reader :client_email, :service

    @@scope = 'https://www.googleapis.com/auth/analytics.readonly'

    def initialize(key)
      @client_email = key.match(/keys\/(.*).json/,1)[1]
      @service = AnalyticsService.new()
      @service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(key),
        scope: @@scope)
    end
  end
end


