class Web < Sinatra::Application
  use Blank
  # include Token
  include Paddle
  
  configure do
    set :views, 'views'
    set :public_folder, 'public'
    set :method_override, true
    set :root, File.join(File.dirname(__FILE__), '..')
  end

  get "/" do
    redirect to "/account" if logged_in?
    slim :index, layout: :'layouts/default'
  end

  get "/login" do
    redirect to "/account" if logged_in?
    slim :'auth/login', layout: :'layouts/default'
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

  post "/logout" do
    session[:user_id] = nil
    flash :success, "Logged out successfully"
    redirect to "/login"              
  end  

  get "/signup" do
    redirect to "/account" if logged_in?
    slim :'auth/signup', layout: :'layouts/default'
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

  get "/reset" do
    slim :'auth/reset', layout: :'layouts/default'
  end

  post "/reset" do
    email = params[:email]
    if email
      MailWorker.perform_async(email, "password_reset")
    end

    flash :success, "A reset password link has been sent to your email. Follow the link to restore access to your account"
    redirect to "/login"      
  end    

  get "/account" do
    reset_token = params[:reset_token]
    if reset_token
      user = User.find_by(reset_token: reset_token)
      if user
        session[:from_token] = true
        session[:user_id] = user.id
        user.refresh_reset_token()
        flash :success, "Successfully logged in. Go ahead and update your password"
        redirect to "/account"
      else
        flash :error, "Invalid reset link"
        redirect to "/account"
      end    
    end

    proceed_if_authenticated do
      slim :'account/account', layout: :'layouts/dash'
    end    
  end

  post "/account" do
    password              = params[:password]
    password_confirmation = params[:password_confirmation]
    old_password          = params[:old_password]
    reset_token           = params[:reset_token]

    # account has been updated and user is supposed to know the old passowrd now
    session[:from_token] = false 

    proceed_if_authenticated do
      if password == password_confirmation
        @user.password = password
        if @user.save
          flash :success, "You have successfully updated your password"
          redirect to "/account"
        else
          flash :error, @user.errors.full_messages.map {|error| "<p>#{error}</p>"}.join
          redirect to "/account"
        end
      else
        flash :error, "Passwords do not match"
        redirect to "/account"
      end
    end
  end

  delete '/account' do
    proceed_if_authenticated do
      @user.destroy
      logout
      flash :success, "You have successfully deleted your account"
      redirect to "/"
    end
  end

  get "/instructions" do
    proceed_if_authenticated do
      slim :'account/instructions', layout: :'layouts/dash'
    end    
  end

  get "/subscription" do
    proceed_if_authenticated do
      @plans = Plan.all
      @subscription = @user.subscription

      slim :'account/subscription', layout: :'layouts/dash'
    end
  end

  get "/subscribed" do
    proceed_if_authenticated do
      flash :success, "You have successfully activated your subscription. Check the instructions on how to proceed further"
      redirect to "/account"
    end
  end

  get "/app" do
    file = File.join(settings.public_folder, "downloads/gasb.zip")
    send_file(file, type: "application/octet-stream", disposition: "attachment")
  end

  post "/paddle" do
    react_to_hook(params)
  end

  get "/terms" do
    slim :'static/terms', layout: :'layouts/default'
  end

  get "/privacy" do
    slim :'static/privacy', layout: :'layouts/default'
  end

  get "/disclaimer" do
    slim :'static/disclaimer', layout: :'layouts/default'
  end
  
  get "/eula" do
    slim :'static/eula', layout: :'layouts/default'
  end

  def proceed_if_authenticated
    if logged_in?
      @user = current_user
      yield
    else
      flash :error, "Please login"
      redirect to "/login"
    end    
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
end
