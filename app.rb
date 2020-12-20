class App < Sinatra::Application
  get "/status/:term" do
    if valid_params(params)
      term = params[:term]
      email = params[:e]   

      repo = ReportRepository.new(parser: CacheReportParser)
      report = repo.find_of_ref(term)

      if report
        if report.can_be_updated?
          RequestWorker.perform_async(term, email)
        end
      else
        report = repo.create(term)
      end
      
      report.to_json
    else
      status 400
    end
  end

  private
    def valid_params(params)
      valid_term = /(now|day|week|month):([0-9]+)/
      
      params[:term].match?(valid_term) && 
      service_account_emails.include?(params[:e])
    end

    def service_account_emails
      Dir["./keys/*.json"].map { |e| e.match(/keys\/(.*).json/,1)[1] }
    end
end

