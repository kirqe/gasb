class RequestWorker
  include Sidekiq::Worker
  
  def perform(term, client_email, args={})    
    account = Account.new(client_email)

    if account
      repo = ReportRepository.new(parser: CacheReportParser)
      new_value = Service.call(term, account)
      
      repo.update(term, { value: new_value, updated_at: Time.now })
    end
  end
end
