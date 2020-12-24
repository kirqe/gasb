class Api < Sinatra::Application
  use Access

  # API
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

  # token for the app
  post "/auth" do
    # if user can login from here, it means they're subscribed
    params = JSON.parse(request.body.read).symbolize_keys

    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password]) && user.active?
      { token: token(user) }.to_json   
    else      
      { error: "wrong email/password or subscription is expired" }.to_json
    end
  end

  def token(user)
    JWT.encode data(user), ENV['jwt_secret'], 'HS256'
  end

  def data(user)
    { 
      exp: Time.now.to_i + 60 * 60 * 24 * 365, # 12 months
      iat: Time.now.to_i,
      iss: ENV['jwt_issuer'],
      email: user.email
    }
  end
end