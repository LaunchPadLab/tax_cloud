module TaxCloud #:nodoc:
  # A <tt>Client</tt> communicates with the TaCloud service.
  class Client < Savon::Client

    # Create a new client.
    def initialize(api_login_id = nil, api_key = nil)
      @api_login_id = api_login_id
      @api_key = api_key

      super TaxCloud::WSDL_URL
    end

    # Make a safe SOAP call.
    # Will raise a TaxCloud::Errors::SoapError on error.
    #
    # === Parameters
    # [method] SOAP method.
    # [body] Body content.
    def request(method, body = {})
      safe do
        super method, :body => body.merge(auth_params)
      end
    end

    # Ping the TaxCloud service.
    #
    # Returns "OK" or raises an error if the TaxCloud service is unreachable.
    def ping
      TaxCloud::Responses::Ping.parse request(:ping)
    end

    private

      # Authorization hash to use with all SOAP requests
      def auth_params
        {
          'apiLoginID' => @api_login_id || TaxCloud.configuration.api_login_id,
          'apiKey' => @api_key || TaxCloud.configuration.api_key
        }
      end

      def safe &block
        begin
          yield
        rescue Savon::SOAP::Fault => e
          raise TaxCloud::Errors::SoapError.new(e)
        end
      end

  end
end
