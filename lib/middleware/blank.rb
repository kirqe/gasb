class Blank
  def initialize(app)
    @app = app
    @scopes = [
      { route: "/signup", reg: /signup\.*/ }      
    ]    
  end

  def call(env)    
    scope = @scopes.find { |scope| env['PATH_INFO'].match?(scope[:reg]) }
    
    if ENV["BLANK"] == "true" && !scope.nil?       
      [200, {"Content-Type" => "text/plain"}, ["Work in progress or the signup is paused. Check back later."]]      
    else
      @app.call(env)
    end
  end
end