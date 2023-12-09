# frozen_string_literal: true

require "json"

run do |_env|
  [200, {
    "content-type": "application/json"
  }, [
    JSON.dump(
      {
        message: "Hello world!"
      }
    )
  ]]
end
