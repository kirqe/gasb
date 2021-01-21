class RequestWorker
  include Sidekiq::Worker
  include Account

  def perform(term, args={})    
    begin
      account = Account.using(ENV["service_account"])
      if account
        repo = ReportRepository.new(parser: CacheReportParser)
        repo.update(term, { queued: true })
        new_value = Service.call(term, account)
        
        repo.update(term, { value: new_value, updated_at: Time.now, queued: false})
      end
    rescue
      repo.update(term, { queued: false })
    end
  end
end
