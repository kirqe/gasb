class Api < Sinatra::Application
  include Token
  use Access

  # /api/status/now:view:123456789:sessions
  # /api/status/now:property:123456789:sessions
  get "/status/:term" do
    term = Term.new(params[:term])
    quota_user = env[:email]
    
    if term.is_valid?
      repo = ReportRepository.new()
      report = repo.find(term.rawString)
      report = repo.create(term.rawString) unless report
      
      if report.can_be_updated?
        term.kind == "view" ? 
        Ga3StatusWorker.perform_async(term.rawString, quota_user) : 
        Ga4StatusWorker.perform_async(term.rawString, quota_user)      
      end
      
      report.to_json
    else
      status 400
    end
  end

  # /api/auth token for the app
  post "/auth" do
    body          = Base64.strict_decode64(request.body.read)    
    params        = JSON.parse(body).symbolize_keys
    email         = params[:email]
    password      = params[:password]
    refresh_token = params[:rt]    
    
    if email && password
      proceed_with_password(email, password)      
    elsif refresh_token
      proceed_with_refresh_token(refresh_token)
    end
  end

  private
    def proceed_with_password(email, password)
      user = User.find_by(email: email)

      if user && user.authenticate(password)
        subscription = user.subscription

        if subscription && subscription.is_active?
          h(user) 
        else
          {
            message: "No subscription or subscription is expired"
          }.to_json
        end
      else
        {
          message: "Invalid email or password"
        }.to_json
      end    
    end

    def proceed_with_refresh_token(refresh_token)
      subscription = Subscription.find_by(refresh_token: refresh_token)

      if subscription && subscription.is_active?
        decode_and_proceed(refresh_token) do
          h(subscription.user)
        end      
      end
    end

    def h(user)
      { 
        token: access_token(user),
        refreshToken: user.subscription.refresh_token,
        expiresIn: ENV['JWT_TTL'].to_i
      }.to_json
    end
end