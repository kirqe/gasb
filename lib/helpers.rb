module Helpers
  def with_backoff
    # https://developers.google.com/analytics/devguides/config/mgmt/v3/errors#backoff  
    for n in (0..5)      
      begin    
        return yield
      rescue Google::Apis::RateLimitError => e
        p "--RateError: #{e}"
        sleep((2 ** n) + rand)
      rescue => e
        p "--GenericError: #{e}"
        break
      end
    end   
  end
end