# frozen_string_literal: true

module Docusearch
  module Model
    # A plain old ruby document object
    class Document
      @documentid = ""
      @sourcename = ""
      @destinationname = ""
      @source = ""
      @destination = ""
      @messagereference = ""
      @documentreference = ""
      @filenameoriginal = ""
      @filename = ""
      @incoming = ""
      @outgoing = ""
      @dataoriginal = ""
      @datafinal = ""
      @created_at = ""

      attr_accessor :documentid, :sourcename, :destinationname, :source, :destination, :messagereference,
                    :documentreference, :filenameoriginal, :filename, :incoming, :outgoing,
                    :dataoriginal, :datafinal, :created_at
    end
  end
end
