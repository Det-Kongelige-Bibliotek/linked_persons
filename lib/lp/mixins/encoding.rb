module LP
  module Encoding

    def encode(uri)
      ERB::Util.url_encode(uri.to_s)
    end

    def decode(uri)
      URI.unescape(uri.to_s)
    end

  end
end