# frozen_string_literal: true

require "elasticsearch"
require "faker"
require "json"
require "base64"
require "date"
require "time"

module Docusearch
  class Error < StandardError; end
  VERSION = "0.1.0"

  # Elasticsearch client
  class Client
    def initialize(domain, auth = {})
      @domain = domain
      @auth = auth
      @client = Elasticsearch::Client.new(url: domain)
    end

    attr_reader :domain
    attr_accessor :client
  end

  # A plain old ruby document object
  class Document
    @id = ""
    @source = ""
    @destination = ""
    @reference = ""
    @filename = ""
    @contents = ""
    @created_at = ""
    @updated_at = ""

    attr_accessor :id, :source, :destination, :reference,
                  :filename, :contents, :created_at, :updated_at

    def initialize; end

    def self.index_name
      "documents"
    end

    def self.index_mapping # rubocop:disable Metrics/MethodLength
      {
        properties: {
          id: { type: "wildcard" },
          source: { type: "keyword" },
          destination: { type: "keyword" },
          reference: { type: "keyword" },
          filename: { type: "keyword" },
          contents: { type: "text" },
          created_at: { type: "date" },
          updated_at: { type: "date" }
        }
      }
    end

    def to_json(*_args)
      hash = {}
      instance_variables.each do |var|
        hash[var.to_s.sub!("@", "")] = instance_variable_get var
      end
      hash.to_json
    end
  end

  # A random amazon order document
  class RandomDocument < Document
    def _random_order_item # rubocop:disable Metrics/MethodLength
      orderitemid = Faker::Invoice.reference

      {
        "AmazonOrderItemCode": orderitemid,
        "SKU": Faker::Barcode.ean,
        "Title": Faker::Book.title,
        "Quantity": Faker::Number.number.to_s,
        "ProductTaxCode": "A_GEN_TAX",
        "ItemPrice": {
          "Component": [
            {
              "Type": "Principal",
              "Amount": {
                "_currency": "USD",
                "__text": Faker::Number.positive.to_s
              }
            },
            {
              "Type": "Shipping",
              "Amount": {
                "_currency": "USD",
                "__text": Faker::Number.positive.to_s
              }
            }
          ]
        }
      }
    end

    def _random_order # rubocop:disable Metrics/MethodLength
      orderid = Faker::Invoice.reference
      buyer_email = Faker::Internet.email
      buyer_name = Faker::Name.name
      buyer_number = Faker::PhoneNumber.phone_number
      created_at = Faker::Time.between_dates(from: Date.today - 30, to: Date.today).iso8601

      {
        "AmazonOrderID": orderid,
        "AmazonSessionID": orderid,
        "OrderDate": created_at,
        "OrderPostedDate": created_at,
        "BillingData": {
          "BuyerEmailAddress": buyer_email,
          "BuyerName": buyer_name,
          "BuyerPhoneNumber": buyer_number
        },
        "FulfillmentData": {
          "FulfillmentMethod": "Ship",
          "FulfillmentServiceLevel": "Standard",
          "Address": {
            "Name": "John Doe",
            "AddressFieldOne": "John Doe",
            "AddressFieldTwo": "4270 Cedar Ave",
            "City": "SUMNER PARK",
            "StateOrRegion": "FL",
            "PostalCode": "32091",
            "CountryCode": "US",
            "PhoneNumber": "407-9999999"
          }
        },
        "Item": (1..100).map { _random_order_item }
      }
    end

    def initialize # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      super

      id = Faker::Internet.uuid
      messagetype = "ORDERS"
      sender = Faker::Company.name
      receiver = Faker::Company.name
      document_created_at = Faker::Time.between_dates(from: Date.today - 30, to: Date.today).iso8601

      datafinal = _random_order
      orderid = datafinal["AmazonOrderID"]

      @id = id
      @source = sender
      @destination = receiver
      @reference = orderid
      @filename = "#{id}_#{messagetype}_#{orderid}_#{document_created_at}.json"
      @contents = JSON.dump(datafinal)
      @created_at = document_created_at
      @updated_at = document_created_at
    end
  end

  # A thin elasticsearch wrapper for documents index
  class Documents
    def initialize(docusearch_client)
      @client = docusearch_client.client
      @index_name = Document.index_name
      @index_mapping = Document.index_mapping

      return if @client.indices.exists? index: @index_name

      @client.indices.create(
        index: @index_name,
        body: {
          mappings: @index_mapping
        }
      )
    end

    def add(document)
      @client.index(index: @index_name, id: document.id, body: document.to_json)
    end

    def get(id)
      @client.get(index: @index_name, id:)
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def search(query = "", offset = 0, limit = 20) # rubocop:disable Metrics/MethodLength
      search_body = {
        sort: [
          "_score",
          { created_at: { order: "desc" } }
        ],
        size: limit,
        from: offset
      }

      if query&.length&.positive?
        search_body["query"] = {
          query_string: {
            query:
          }
        }
      end

      @client.search(
        index: @index_name,
        body: search_body
      )
    end
  end
end
