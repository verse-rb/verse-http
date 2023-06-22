# frozen_string_literal: true

module Verse
  module Http
    module Auth
      # A simple role backend that fetches roles from the
      # Verse::Auth::Context helper system
      module SimpleRoleBackend
        module_function

        def fetch(rolename)
          Verse::Auth::Context.roles.fetch(rolename.to_sym) do
            raise "Role `#{rolename}` not set"
          end
        end
      end
    end
  end
end
