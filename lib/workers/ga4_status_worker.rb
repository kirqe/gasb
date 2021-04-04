class Ga4StatusWorker
  include Sidekiq::Worker
  include Helpers
  sidekiq_options queue: 'ga4_status'

  def perform(term, quota_user, args={})
    term = Term.new(term)
    serviceClass = Service::GA4::BaseService.select(term.label)

    if serviceClass
        service = serviceClass.new("keys/service_account.json")

        repo = ReportRepository.new()    
        repo.update(term.rawString, { queued: true })

        value = with_backoff do
          resp = service.call(term, quota_user)
          
          # there's no .totals, .maximums for some reason
          if resp.row_count && resp.row_count > 0 
            value = resp.rows.reduce(0) do |acc, row|
              acc + row.metric_values.reduce(0) {|acc, v| acc + v.value.to_i }
            end
          else
            value = 0
          end   
        end
        
        repo.update(term.rawString, { value: value, updated_at: Time.now, queued: false})
    end
  end
end

