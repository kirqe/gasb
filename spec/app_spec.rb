require 'spec_helper'
require 'rack/test'

describe 'App' do
  include Rack::Test::Methods

  def app
    App.new
  end
  
  describe 'GET /status' do
    
    context 'when params are invalid' do
      it 'responds with 400' do
        get '/status/week:193451539'
        expect(last_response.status).to eq(400)
      end
    end

    context 'when params are valid' do

      it 'returns a hash of values' do
        report = double('student')



        get '/status/week:193451539?ce=gamb-sa@gamb-294914.iam.gserviceaccount.com'
        resp = JSON.parse(last_response.body)
        
        expect(resp["term"]).to eq("week:193451539")
        expect(resp["value"]).to eq(0)
      end

      it 'responds with 200' do
        get '/status/week:193451539?ce=gamb-sa@gamb-294914.iam.gserviceaccount.com'
        expect(last_response.status).to eq(200)
      end
    end    
  end
end

