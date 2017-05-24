module LP

  ##
  # Rack middleware to insert Access-Control-Allow-Origin 
  # header to the responses.
  #
  class ResponseHeadersHandler
    
    def initialize(app)
      @app = app
    end
    
    def call(env)
      status, headers, response = @app.call(env)
          
      headers['Access-Control-Allow-Origin'] = '*' 
      [status, headers, response]
    end

  end

end
