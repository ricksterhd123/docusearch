# frozen_string_literal: true

require "docusearch"
require "cgi"
require "json"

ELASTICSEARCH_DOMAIN = "http://localhost:9200"
client = Docusearch::Model::Client.new(ELASTICSEARCH_DOMAIN)
documents = Docusearch::Model::Documents.new(client)

run do |env|
  method = env["REQUEST_METHOD"]
  query_string = CGI.unescape(env["QUERY_STRING"] || "")

  if method == "GET"
    query_parameters = query_string.split("&").map do |x|
      k, v = x.split("=")
      [k, v]
    end.to_h

    query_string = query_parameters["q"] or ""
    response = JSON.dump(documents.search(query_string))

    [200, { "content-type" => "application/json" }, [response]]
  end
end
