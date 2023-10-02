module Verse
  module Http
    module Rest

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
        record:,
        show: [:get, ":id"],
        index: [:get, ""],
        create: [:post, ""],
        update: [:patch, ":id"],
        destroy: [:delete, ":id"],
        extra_filters: [],
        blacklist_filters: [],
        authorized_included: [],
        service: :service
      )

        instance_exec(
          record,
          show,
          service,
          authorized_included,
          &Verse::Http::Rest.instance_method(:inject_show).bind(self)
        ) if show

        instance_exec(
          record,
          index,
          extra_filters,
          blacklist_filters,
          service,
          authorized_included,
          &Verse::Http::Rest.instance_method(:inject_index).bind(self)
        ) if index

        # instance_exec(
        #   record,
        #   create,
        #   service,
        #   &Verse::Http::Rest.instance_method(:inject_create).bind(self)
        # ) if create

        # instance_exec(
        #   record,
        #   update,
        #   service,
        #   &Verse::Http::Rest.instance_method(:inject_update).bind(self)
        # ) if update

        # instance_exec(
        #   record,
        #   destroy,
        #   service,
        #   &Verse::Http::Rest.instance_method(:inject_destroy).bind(self)
        # ) if destroy
      end

      # :nodoc:
      def inject_show(record, show_path, service, authorized_included)
        expose on_http(*show_path) do
          desc "Show data for #{record.name}"
          input do
            required(:id).value(:integer)
          end
        end
        def show
          send(service).show(params[:id])
        end
      end

      # :nodoc:
      def inject_index(record, index_path, extra_filters, blacklist_filters, service, authorized_included)
        blacklist_filters = blacklist_filters.map(&:to_s)
        extra_filters = extra_filters.map(&:to_s)

        exposed = build_expose on_http(*index_path) do
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

        define_method(:index) do
          included = (params[:included] || []) & authorized_included

          send(service).index(
            params.fetch(:filter, {}),
            included:,
            page: params.fetch(:page, 1),
            items_per_page: params.fetch(:per_page, 100),
            sort: params[:sort]
          )
        end

        self.attach_exposition(:index, exposed)
      end

    end
  end
end
