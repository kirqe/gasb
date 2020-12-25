class Access
  def initialize(app)
    @app = app
    @scopes = [
      { route: "/api/status/:term", reg: /api\/status\/(now|day|week|month):([0-9]+)/ }
    ]
  end

  def call(env)
    scope = @scopes.find { |scope| env['PATH_INFO'] =~ scope[:reg] }
    scope ? validate(env) : @app.call(env)
  end

  def validate(env)
    begin
      hmac_secret = ENV['JWT_SECRET']
      
      options = { 
        algorithm: 'HS256', 
        iss: ENV['JWT_ISSUER'],
        verify_iss: true
      }

      bearer = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
      data, header = JWT.decode bearer, hmac_secret, true, options

      env[:email] = data[:email]
      @app.call(env)
    
    rescue JWT::ExpiredSignature
      [403, { 'Content-Type' => 'text/plain' }, ['The token has expired.']] 
    rescue JWT::InvalidIssuerError
      [403, { 'Content-Type' => 'text/plain' }, ['The token does not have a valid issuer.']]           
    rescue JWT::InvalidIatError
      [403, { 'Content-Type' => 'text/plain' }, ['The token does not have a valid "issued at" time.']]         
    rescue JWT::DecodeError
      [401, { 'Content-Type' => 'text/plain' }, ['A token must be passed.']]    
    end
  end
end
