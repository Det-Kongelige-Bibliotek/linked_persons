Bundler.require

require 'sinatra'
require 'thin'
require 'rack/ldp'
require 'net/http'
require_relative '../lib/linked_persons'

module App
  class Server < Sinatra::Base
    
    configure do
      set :environment, :production
      set :bind, '0.0.0.0'
      set :port, 443
      set :server, "thin"
    end

    use LP::ResponseHeadersHandler
    use LP::RequestHeadersHandler

    # The following middleware cannot handle 
    # "Accept: application/json, text/plain, */*"
    use Rack::LDP::ContentNegotiation 
    # use Rack::LinkedData::ContentNegotiation
    use Rack::LDP::Errors
    use Rack::LDP::Responses
    use Rack::LDP::Requests

    get '/persons/' do
      # We aim to support application/x-www-form-urlencoded, like so:
      #  persons/?uri[]=uri1&uri[]=uri2
      # ERB::Util.url_encode("http://viaf.org/viaf/36915259")
      # URI.unescape("http%3A%2F%2Fviaf.org%2Fviaf%2F36915259")
      # Example request
      #   http://0.0.0.0:9292?uri[]=http%3A%2F%2Fviaf.org%2Fviaf%2F36915259&uri[]=http%3A%2F%2Fviaf.org%2Fviaf%2F27203135
      #   curl -ig http://0.0.0.0:9292/persons/?uri[]="http%3A%2F%2Fviaf.org%2Fviaf%2F36915259"\&uri[]="http%3A%2F%2Fviaf.org%2Fviaf%2F27203135"
      #   curl -ig http://0.0.0.0:9292/persons/?uri="http%3A%2F%2Fviaf.org%2Fviaf%2F36915259"
      #   curl -ig http://0.0.0.0:9292/persons/?uri="http%3A%2F%2Fwww.wikidata.org%2Fentity%2FQ1607626"
      #
      ###################################
      #       Example transaction       #
      ###################################
      # GET persons/?uri[]=uri1&uri[]=uri2
      #
      # <?uri[]=uri1&uri[]=uri2> a ldp:BasicContainer;
      #   ldp:contains <?uri=uri1>, <?uri=uri1>.
      #
      # <?uri=uri1> a schema:Person;
      #   schema:sameAs <uri1>;
      #   ... (all the aggregated data associated is this URI)
      #
      # <?uri=uri2> a schema:Person;
      #   schema:sameAs <uri2>;
      #   ... (all the aggregated data associated is this URI)

      relative_uri = /\/persons\/(.*)$/.match(request.url)[1]

      uri_param = params[:uri]
      case uri_param
      when String then
        LP::Person.new(relative_uri).fetch_for_uri_str!(uri_param)
      when Array then 
        LP::Container.new(relative_uri).fetch_for_uri_strs!(uri_param)  
      else
        raise LP::Errors::BadParameters
      end 
        
    end
  
  end
end