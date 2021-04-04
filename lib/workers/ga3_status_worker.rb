class Ga3StatusWorker
  include Sidekiq::Worker
  include Helpers
  sidekiq_options queue: 'ga3_status'

  def perform(term, quota_user, args={})
    term = Term.new(term)
    serviceClass = Service::GA3::BaseService.select(term.label)

    if serviceClass
      service = serviceClass.new("keys/service_account.json")

      repo = ReportRepository.new()    
      repo.update(term.rawString, { queued: true })
              
      value = with_backoff do
        service.call(term, quota_user) || 0
      end
    
      repo.update(term.rawString, { value: value, updated_at: Time.now, queued: false})     
    end
  end
end


