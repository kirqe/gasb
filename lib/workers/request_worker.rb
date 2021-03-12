class RequestWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'status'

  def perform(term, quota_user, args={})    
    term = Term.new(term)
    id = term.rawString
    
    begin
      account = Account.new(ENV["G_SERVICE_ACCOUNT"])
      repo = ReportRepository.new(parser: CacheReportParser)
      repo.update(id, { queued: true })
      new_value = Service.call(term, account, quota_user)
      repo.update(id, { value: new_value, updated_at: Time.now, queued: false})
    rescue
      repo.update(id, { queued: false })
    end
  end
end