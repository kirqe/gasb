class Web < Sinatra::Application
  configure do
    enable :sessions
    set :views, 'views'
    set :public_folder, 'public'
  end

  get "/" do
    redirect to "/account" if logged_in?
    slim :index
  end

  get "/login" do
    redirect to "/account" if logged_in?
    slim :'auth/login'    
  end

  post "/login" do
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash :success, "Logged in successfully"
      redirect to "/account"          
    else
      flash :error, "Invalid email or password"      
      redirect to "/login"
    end
  end  

  get "/signup" do
    redirect to "/account" if logged_in?
    slim :'auth/signup'
  end

  post "/signup" do
    user = User.new(email: params[:email], password: params[:password])
    if user.save
      session.delete(:email_attempt)
      redirect to "/login"
    else
      session[:email_attempt] = params[:email]
      flash :error, user.errors.full_messages.map {|error| "<p>#{error}</p>"}.join
      redirect to "/signup"
    end 
  end

  get "/account" do
    if logged_in?
      @user = current_user
      slim :account    
    else
      flash :error, "Please login"
      redirect to "/login"
    end
  end

  get "/validate/:plan_id" do
    if logged_in?
      plan_id = params[:plan_id]
      user = current_user

      if Subscription.validate(plan_id, user)
        flash :success, "You have successfully activated the subscription. Check the instructions on how to proceed further."
        redirect to "/account"
      else
        flash :error, "Something went wrong"
        redirect to "/account"
      end
    else
      flash :error, "Please login"
      redirect to "/login"
    end
  end

  get "/download" do
    flash :error, "Please login"
    redirect to "/login" unless logged_in?
    send_file File.join(settings.public_folder, 'app/gasb.dmg')
  end

  helpers do
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]      
    end

    def logged_in?
      !!session[:user_id]
    end

    def logout
      @current_user = nil
      session.delete(:user_id)
    end

    def flash(key, value)
      session[:flash] = { key => value }
    end    
  end  

  def valid_params(params)
    valid_term = /(now|day|week|month):([0-9]+)/
    
    params[:term].match?(valid_term) && 
    service_account_emails.include?(params[:e])
  end

  def service_account_emails
    Dir["./keys/*.json"].map { |e| e.match(/keys\/(.*).json/,1)[1] }
  end
end

