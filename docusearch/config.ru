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
    run lambda { |env|
          req = Rack::Request.new(env)

          if req.get?
            _, id = req.path.split("/").slice(1..)

            if id
              document = documents.get(id)
              return [200, { "content-type" => "application/json" }, [JSON.dump(document)]] if document

              return [404, {}, []]
            end

            query = req.params["query"] || ""
            offset = (req.params["offset"] || "0").to_i
            limit = (req.params["limit"] || "20").to_i
            [200, { "content-type" => "application/json" }, [JSON.dump(documents.search(query, offset, limit))]]
          end
        }
  end
end

run app
