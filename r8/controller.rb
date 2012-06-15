# coding: UTF-8
# 
# SETTING
#
# $ vim app/controllers/applications_controller.rb
# class ApplicationsController
#   include Strut::Controller
#   include R8::Controller
#
# $ vim app/controllers/items_controller.rb
# class ItemsController
#   strut_controller Item
#   r8_controller Item
#
#   # @i18n_opts
#   def index_i18n
#     @i18n_opts = { items_name: 'AAAAAAAAAAAA' }
#   end
#   def show_i18n
#     @i18n_opts = { item_name: 'AAAAAAAAAAA' }
#   end
#
module R8
  module Controller
    extend ActiveSupport::Concern

    module ClassMethods
      include R8::Controller::Filter
      def r8_controller clazz, options={}
        table_name = clazz.to_s.tableize.gsub("/","_")
        file_name = clazz.to_s.underscore.gsub("/","_")
        actions = R8::Model::Holder.new options

        # define_before_filter
        i18n_controller_filter clazz, table_name, file_name, actions
        
      end
    end

  end
end
