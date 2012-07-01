# coding: UTF-8
# 
# SETTING
#
# $ vim app/controllers/items_controller.rb
# class ItemsController
#   strut_controller Item
#   include R8::Controller
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

    included do 
      before_filter :index_i18n ,only: [:index]
      before_filter :show_i18n  ,only: [:show]
    end

    module ClassMethods

      # params[:item_id] => @item
      def set_obj names
        names.each do |name|
          define_method "set_#{name}" do
            instance_variable_set("@#{name}",name.classify.constantize.find(params["#{name}_id".to_sym]))
          end
        end
      end

    end

    module InstanceMethods

      # i18n
      def index_i18n
        @i18n_opts = {}
      end
      def show_i18n
        @i18n_opts = {}
      end

    end


  end
end
