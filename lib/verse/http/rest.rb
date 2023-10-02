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
            service
          )
        elsif mod < Verse::Service::Base
          inject_service(mod,
            show,
            index,
            create,
            update,
            destroy,
            repository
          )
        else
          raise "Can be used only on class inheriting from `Verse::Exposition::Base` or `Verse::Service::Base`"
        end
      end

      def inject_exposition(mod,
        record,
        show,
        index,
        create,
        update,
        destroy,
        extra_filters,
        blacklist_filters,
        authorized_included,
        service
      )
        inject_expo_show(mod, record, show, service, authorized_included) if show

        inject_expo_index(mod, record, index, extra_filters,
          blacklist_filters, service, authorized_included) if index
      end

      def inject_service(mod,
        show,
        index,
        create,
        update,
        destroy,
        repository
      )
        inject_service_show(mod, repository) if show
        inject_service_index(mod, repository) if index
        inject_service_create(mod, repository) if create
      end

      # :nodoc:
      def inject_service_show(mod, repository)
        mod.define_method(:show) do |id|
          send(repository).find_by!({ id: id })
        end
      end

      def inject_service_create(mod, repository)
        mod.define_method(:create) do |attributes|
          send(repository).create(attributes)
        end
      end

      def inject_service_index(mod, repository)
        mod.define_method(:index) do |filter, included:, page:, items_per_page:, sort:|
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
        # expose on_http(*show_path) do
        #   desc "Show data for #{record.name}"
        #   input do
        #     required(:id).value(:integer)
        #   end
        # end
        # def show
        #   send(service).show(params[:id])
        # end
      end

      # :nodoc:
      def inject_expo_index(mod, record, index_path, extra_filters, blacklist_filters, service, authorized_included)
        blacklist_filters = blacklist_filters.map(&:to_s)
        extra_filters = extra_filters.map(&:to_s)

        exposed = mod.build_expose mod.on_http(*index_path) do
          desc "Index data for #{record.name}"
          input do
            optional(:page).value(gt?: 0)
            optional(:per_page).value(gt?: 0, lt?: 1001)
            optional(:sort).value(:string)
            optional(:filter).hash do
              record.fields.each do |field|
                next if blacklist_filters.include?(field[0])
                optional(field[0])
              end
              extra_filters.each do |field|
                optional(field.to_sym).maybe(:string)
              end
            end
            optional(:included).array(:string)
          end
        end

        mod.define_method(:index) do
          included = (params[:included] || []) & authorized_included

          send(service).index(
            params.fetch(:filter, {}),
            included:,
            page: params.fetch(:page, 1),
            items_per_page: params.fetch(:per_page, 100),
            sort: params[:sort]
          )
        end

        mod.attach_exposition(:index, exposed)
      end

    end
  end
end
