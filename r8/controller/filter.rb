# coding: UTF-8

module R8
  module Controller
    module Filter

      def r8_controller_filter clazz,table_name,file_name,actions
        # before_filter
        class_eval do
          before_filter :index_i18n ,only: actions.find_names(:index)
          before_filter :show_i18n  .only: actions.find_names(:show)
        end
      end

      # index_i18n
      define_method :index_i18n do
        @i18n_opts = {}
      end

      # show_i18n
      define_method :show_i18n do
        @i18n_opts = {}
      end

    end
  end
end
