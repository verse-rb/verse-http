# frozen_string_literal: true

module Verse
  module Http
    module Rest
      module_function

      # use `inject` on exposition to inject restful routes
      #
      # @example
      #   class MyExposition < Verse::Exposition::Base
      #     use_service MyRecordService
      #     inject Verse::Http::Rest, record: MyRecord
      #   end
      #
      # @param record [Class] record structure expected to be used by the exposition.
      # This will define what fields are expected to be present in the params.
      #
      # @param show [Array]     path to the show action. Format is [:(get|post|patch|put|delete), "path"]
      #                         Default is [:get, "/:id"]
      #                         If falsey value, it won't generate the route
      # @param index [Array]    path to the index action.  Format is [:(get|post|patch|put|delete), "path"]
      #                         Default is [:get, "/"]
      #                         If falsey value, it won't generate the route
      # @param create [Array]   path to the create action.  Format is [:(get|post|patch|put|delete), "path"]
      #                         Default is [:post, "/"]
      #                         If falsey value, it won't generate the route
      # @param update [Array]   path to the update action.  Format is [:(get|post|patch|put|delete), "path"]
      #                         Default is [:patch, "/:id"]
      #                         If falsey value, it won't generate the route
      # @param destroy [Array]  path to the destroy action.  Format is [:(get|post|patch|put|delete), "path"].
      #                         Default is [:delete, "/:id"]
      #                         If falsey value, it won't generate the route
      #
      # @param extra_filters [Array] extra filters to be applied to the index action.
      # @param blacklist_filters [Array] filters to be ignored on the index action.
      # @param service [Symbol] the name of the service object to be used, default `service`.
      #
      def call(
        mod,
        record: nil,
        show: [:get, ":id"],
        index: [:get, ""],
        create: [:post, ""],
        update: [:patch, ":id"],
        destroy: [:delete, ":id"],
        extra_filters: [],
        blacklist_filters: [],
        authorized_included: [],
        service: :service,
        repository: :repo
      )

        if mod < Verse::Exposition::Base
          raise ArgumentError, "record is required" unless record

          inject_exposition(mod,
                            record,
                            show,
                            index,
                            create,
                            update,
                            destroy,
                            extra_filters,
                            blacklist_filters,
                            authorized_included,
                            service)
        elsif mod < Verse::Service::Base
          inject_service(mod,
                         show,
                         index,
                         create,
                         update,
                         destroy,
                         repository)
        else
          raise "Can be used only on class inheriting from `Verse::Exposition::Base` or `Verse::Service::Base`"
        end
      end

      def inject_exposition(
        mod, record, show,
        index, create, update,
        destroy, extra_filters, blacklist_filters,
        authorized_included, service
      )
        show && inject_expo_show(mod, record, show, service, authorized_included)
        index && inject_expo_index(mod, record, index, extra_filters,
                                   blacklist_filters, service, authorized_included)
        update && inject_expo_update(mod, record, update, service)
        create && inject_expo_create(mod, record, create, service)
        destroy && inject_expo_destroy(mod, record, destroy, service)
      end

      def inject_service(
        mod, show, index,
        create, update, destroy,
        repository
      )
        show && inject_service_show(mod, repository)
        index && inject_service_index(mod, repository)
        create && inject_service_create(mod, repository)
        update && inject_service_update(mod, repository)
        destroy && inject_service_destroy(mod, repository)
      end

      # :nodoc:
      def inject_service_show(mod, repository)
        mod.define_method(:show) do |id, included: []|
          send(repository).find_by!({ id: id }, included: included)
        end
      end

      def inject_service_create(mod, repository)
        mod.define_method(:create) do |attributes|
          send(repository).create(attributes)
        end
      end

      def inject_service_index(mod, repository)
        mod.define_method(:index) do |filter, included: [], page: 1, items_per_page: 100, sort: nil|
          send(repository).index(
            filter,
            included: included,
            page: page,
            items_per_page: items_per_page,
            sort: sort
          )
        end
      end

      def inject_service_update(mod, repository)
        mod.define_method(:update) do |id, attributes|
          send(repository).update!(id, attributes)
        end
      end

      def inject_service_destroy(mod, repository)
        mod.define_method(:destroy) do |id|
          send(repository).delete!(id)
        end
      end

      # :nodoc:
      def inject_expo_show(mod, record, show_path, service, authorized_included)
        exposed = mod.build_expose mod.on_http(*show_path) do
          desc "Show a record `#{record.name}`"
          input do
            required(:id).value(:integer)
            optional(:included).array(:string)
          end
        end

        mod.define_method(:show) do
          included = (params[:included] || []) & authorized_included
          send(service).show(
            params[:id],
            included: included
          )
        end

        mod.attach_exposition(:show, exposed)
      end

      # :nodoc:
      def inject_expo_index(mod, record, index_path, extra_filters, blacklist_filters, service, authorized_included)
        blacklist_filters = blacklist_filters.map(&:to_s)

        exposed = mod.build_expose mod.on_http(*index_path) do
          desc "Index data for #{record.name}"
          input do
            optional(:page).value(:integer).value(gt?: 0)
            optional(:per_page).value(:integer).value(gt?: 0, lt?: 1001)
            optional(:sort).value(:string)
            optional(:filter).hash do
              record.fields.each do |field|
                next if blacklist_filters.include?(field[0])

                optional(field[0])
              end

              extra_filters.each do |field|
                case field
                when String, Symbol
                  optional(field.to_sym).maybe(:string)
                else
                  field[1].call(optional(field[0].to_sym))
                end
              end
            end
            optional(:included).array(:string)
          end
        end

        mod.define_method(:index) do
          included = (params[:included] || []) & authorized_included

          send(service).index(
            params.fetch(:filter, {}),
            included: included,
            page: params.fetch(:page, 1),
            items_per_page: params.fetch(:per_page, 100),
            sort: params[:sort]
          )
        end

        mod.attach_exposition(:index, exposed)
      end

      def inject_expo_create(mod, record, create_path, service)
        exposed = mod.build_expose mod.on_http(*create_path) do
          desc "Create a new record `#{record.name}`"
          input do
            record.fields.each do |field|
              optional(field[0])
            end
          end
        end

        mod.define_method(:create) do
          out = send(service).create(params)
          server.response.status = 201

          out
        end

        mod.attach_exposition(:create, exposed)
      end

      def inject_expo_update(mod, record, update_path, service)
        exposed = mod.build_expose mod.on_http(*update_path) do
          desc "Update a record `#{record.name}`"
          input do
            required(record.primary_key).value(:integer)

            record.fields.each do |k, _|
              next if k == record.primary_key

              optional(k)
            end
          end
        end

        mod.define_method(:update) do
          send(service).update(params[:id], params)
        end

        mod.attach_exposition(:update, exposed)
      end

      def inject_expo_destroy(mod, record, destroy_path, service)
        exposed = mod.build_expose mod.on_http(*destroy_path) do
          desc "Destroy a record `#{record.name}`"
          input do
            required(:id).value(:integer)
          end
        end

        mod.define_method(:destroy) do
          send(service).destroy(params[:id])
          server.response.status = 204
        end

        mod.attach_exposition(:destroy, exposed)
      end
    end
  end
end
