module Token
  def decode_and_proceed(refresh_token)
    begin
      hmac_secret = ENV['JWT_SECRET']

      options = { 
        algorithm: 'HS256', 
        iss: ENV['JWT_ISSUER'],
        verify_iss: true
      }

      JWT.decode refresh_token, hmac_secret, true, options
      
      yield

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
  
  def access_token(user)
    h = access_token_data(user)
    JWT.encode(h, ENV['JWT_SECRET'], 'HS256')
  end

  def refresh_token(user, next_bill_date, subscription_id, subscription_plan_id)
    h = refresh_token_data(user, next_bill_date, subscription_id, subscription_plan_id)
    JWT.encode(h, ENV['JWT_SECRET'], 'HS256')    
  end

  def access_token_data(user)
    {
      exp: Time.now.to_i + ENV['JWT_TTL'].to_i,#60 * 60 * 2,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      email: user.email
    }
  end

  def refresh_token_data(user, next_bill_date, subscription_id, subscription_plan_id)
    {
      exp: Time.parse(next_bill_date).to_i + 60 * 5,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      plan_id: subscription_plan_id,
      subscription_id: subscription_id
    }
  end  
end
