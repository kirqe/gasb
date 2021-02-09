class Access
  def initialize(app)
    @app = app
    @scopes = [
      { route: "/status/:term", reg: /status\/(now|day|week|month):([0-9]+)/ }
    ]
  end

  def call(env)
    scope = @scopes.find { |scope| env['PATH_INFO'].match?(scope[:reg]) }
    scope.nil? ? @app.call(env) : validate(env)
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
      data = data.symbolize_keys

      env[:email] = data[:email]


      @app.call(env)

    rescue JWT::ExpiredSignature
      [403, { 'Content-Type' => 'application/json' }, [ { message: 'Еxpired token' }.to_json ]] 
    rescue JWT::InvalidIssuerError
      [403, { 'Content-Type' => 'application/json' }, [ { message: 'Invalid issuer' }.to_json ]]           
    rescue JWT::InvalidIatError
      [403, { 'Content-Type' => 'application/json' }, [ { message: 'Invalid iat' }.to_json ]]         
    rescue JWT::DecodeError
      [401, { 'Content-Type' => 'application/json' }, [ { message: 'Missing token' }.to_json ]]    
    end
  end
end
