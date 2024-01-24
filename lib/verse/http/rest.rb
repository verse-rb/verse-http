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
      # @param delete [Array]  path to the delete action.  Format is [:(get|post|patch|put|delete), "path"].
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
        delete: [:delete, ":id"],
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
                            delete,
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
                         delete,
                         repository)
        else
          raise "Can be used only on class inheriting from `Verse::Exposition::Base` or `Verse::Service::Base`"
        end
      end

      def inject_exposition(
        mod, record, show,
        index, create, update,
        delete, extra_filters, blacklist_filters,
        authorized_included, service
      )
        show && inject_expo_show(mod, record, show, service, authorized_included)
        index && inject_expo_index(mod, record, index, extra_filters,
                                   blacklist_filters, service, authorized_included)
        update && inject_expo_update(mod, record, update, service)
        create && inject_expo_create(mod, record, create, service)
        delete && inject_expo_delete(mod, record, delete, service)
      end

      def inject_service(
        mod, show, index,
        create, update, delete,
        repository
      )
        show && inject_service_show(mod, repository)
        index && inject_service_index(mod, repository)
        create && inject_service_create(mod, repository)
        update && inject_service_update(mod, repository)
        delete && inject_service_delete(mod, repository)
      end

      # :nodoc:
      def inject_service_show(mod, repository)
        mod.define_method(:show) do |id, included: []|
          send(repository).find_by!({ id: id }, included: included)
        end
      end

      def inject_service_create(mod, repository)
        mod.define_method(:create) do |attributes|
          id = send(repository).create(attributes)
          send(repository).find(id)
        end
      end

      def inject_service_index(mod, repository)
        mod.define_method(:index) do |filter, included: [], page: 1, items_per_page: 100, sort: nil, query_count: true|
          send(repository).index(
            filter,
            included: included,
            page: page,
            items_per_page: items_per_page,
            sort: sort,
            query_count: query_count
          )
        end
      end

      def inject_service_update(mod, repository)
        mod.define_method(:update) do |id, attributes|
          repo = send(repository)
          repo.update!(id, attributes)
          repo.find(id)
        end
      end

      def inject_service_delete(mod, repository)
        mod.define_method(:delete) do |id|
          send(repository).delete!(id)
        end
      end

      # :nodoc:
      def inject_expo_show(mod, record, show_path, service, authorized_included)
        exposed = mod.build_expose mod.on_http(*show_path) do
          desc "Show a record `#{record.name}`"
          input do
            field(:id, Integer)
            field(:included, Array, of: String).optional
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
            field?(:page, Integer).rule("must be positive"){ |v| v > 0 }
            field?(:per_page, Integer).rule("must be between 1 and 1000"){ |v| v > 0 && v < 1001 }
            field?(:sort, String)
            field?(:filter, Hash) do
              record.fields.each do |field|
                next if blacklist_filters.include?(field[0])

                field?(field[0], Object)
              end

              extra_filters.each do |f|
                case f
                when String, Symbol
                  field?(f.to_sym, String)
                else
                  f[1].call(field?(f[0].to_sym, Object))
                end
              end
            end
            field?(:included, Array, of: String)
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
            record.fields.each do |f|
              field?(f[0])
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
            field(record.primary_key, Integer)

            record.fields.each do |k, _|
              next if k == record.primary_key

              field?(k, Object)
            end
          end
        end

        mod.define_method(:update) do
          out = send(service).update(params[:id], params.except(:id))

          server.response.status = 204 if out.nil?
          out
        end

        mod.attach_exposition(:update, exposed)
      end

      def inject_expo_delete(mod, record, delete_path, service)
        exposed = mod.build_expose mod.on_http(*delete_path) do
          desc "delete a record `#{record.name}`"
          input do
            field(:id, Integer)
          end
        end

        mod.define_method(:delete) do
          out = send(service).delete(params[:id])
          server.response.status = 204 if out.nil?
          out
        end

        mod.attach_exposition(:delete, exposed)
      end
    end
  end
end
