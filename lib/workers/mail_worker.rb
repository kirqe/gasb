class MailWorker
  include Sidekiq::Worker
  
  def perform(email, operation)
    user = User.find_by(email: email)
    if user
      email_params = reset(user) if operation == "password_reset"
      # email_params = confirm(user) if operation == "confirm_account"
      Pony.mail(configure_block.merge!(email_params))      
    end
  end  

  private
    def configure_block
      {
        via: :smtp,
        via_options: {
          address: ENV['MAILER_HOSTNAME'],
          port: ENV['MAILER_PORT'],
          user_name: ENV['MAILER_USERNAME'],
          password: ENV['MAILER_PASSWORD'],
          authentication: :plain, # :plain, :login, :cram_md5, no auth by default
          domain: ENV['MAILER_DOMAIN'],
        }
      }
    end

    def reset(user)
      reset_link = "#{ENV['BASE_URL']}/account?reset_token=#{user.reset_token}"
      {
        to: user.email,
        from: ENV["MAILER_FROM"],
        subject: "#{ENV['NAME']} [Reset password]",
        html_body: "Hey there! Here is your <a href='#{reset_link}'>reset password link</a>. Follow it to restore access to your account.",
        body: "Hey there! Here is your reset password link. Follow it to restore access to your account. #{reset_link}"
      }    
    end
end
