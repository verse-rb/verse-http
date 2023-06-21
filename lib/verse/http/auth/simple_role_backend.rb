# frozen_string_literal: true

module Verse
  module Http
    module Auth
      class SimpleRoleBackend
        def fetch(rolename)
          Verse::Auth::Context.roles.fetch(rolename)
        end
      end
    end
  end
end
