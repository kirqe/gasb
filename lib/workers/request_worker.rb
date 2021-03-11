class RequestWorker
  include Sidekiq::Worker
  include Account
  sidekiq_options queue: 'status'

  def perform(term, quota_user, args={})    
    term = Term.new(term)
    id = term.rawString
    
    begin
      account = Account.using(ENV["SERVICE_ACCOUNT"])
      
      if account
        repo = ReportRepository.new(parser: CacheReportParser)
        repo.update(id, { queued: true })
        new_value = Service.call(term, account, quota_user)
        
        repo.update(id, { value: new_value, updated_at: Time.now, queued: false})
      end
    rescue
      repo.update(id, { queued: false })
    end
  end
end
