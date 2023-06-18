# frozen_string_literal: true

require_relative "../validation/contract"

module Verse
  module Config
    class Schema < Verse::Validation::Contract
      SERVICE_NAME = /[a-z0-9_-]+/.freeze
      PLUGIN_NAME = /[a-z0-9_]+( <[a-zA-Z0-9:]+>)?/.freeze

      params do
        optional(:port).filled(:int).value(lt?: 2**16, gt?: 0)
        optional(:bind).filled(:string)
        optional(:show_error_details).filled(:bool)

      end

      rule(:service_name) do
        key.failure(:bad_format) unless value =~ SERVICE_NAME
      end

      rule(:plugins).each do |index:|
        next if value[:name] =~ PLUGIN_NAME

        key([:plugin, :name, index]).failure(:bad_format)
      end
    end
  end
end
