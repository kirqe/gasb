class RequestWorker
  include Sidekiq::Worker
  
  def perform(term, client_email, args={})    
    repo = ReportRepository.new(parser: CacheReportParser)
    service = ServiceRegistry.select_service(term, client_email)

    repo.update(term, { value: service.call, updated_at: Time.now })    
  end
end


