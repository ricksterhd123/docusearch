# frozen_string_literal: true

require "rack"
require "docusearch"
require "cgi"
require "json"

ELASTICSEARCH_DOMAIN = "http://localhost:9200"
client = Docusearch::Client.new(ELASTICSEARCH_DOMAIN)
documents = Docusearch::Documents.new(client)

app = Rack::Builder.new do
  use Rack::CommonLogger
  use Rack::Runtime

  map "/documents" do
    run do |env|
      req = Rack::Request.new(env)
      # Handle the following requests
      # GET /documents
      # GET /documents/:id
      if req.get?
        _, id, *rest = req.path.split("/").slice(1..)
        return [404, {}, []] if rest.length.positive?

        # GET /documents/:id
        if id
          document = documents.get(id)
          return [200, { "content-type" => "application/json" }, [JSON.dump(document)]] if documen

          return [404, {}, []]
        end
        # GET /documents
        # extract query parameters out
        # TODO: add proper validation
        query = req.params["query"] || ""
        offset = (req.params["offset"] || "0").to_i
        limit = (req.params["limit"] || "20").to_i
        [200, { "content-type" => "application/json" }, [JSON.dump(documents.search(query, offset, limit))]]
      end
    end
  end
end

run app
