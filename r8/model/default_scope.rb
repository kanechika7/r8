# coding: UTF-8
#
# よく使うScope を定義
#
# SETTING
#
#   $ vim app/models/item/scope.rb
#
#   class Item
#     module Scope
#       include R8::Model::DefaultScope
#
#

module R8
  module Model
    module DefaultScope

      # ActiveRecord
      ActiveSupport.on_load(:active_record) do
        require 'r8/model/default_scope/active_record_scope'
        include R8::Model::DefaultScope::ActiveRecordScope
      end

      # Mondoid
      if defined? ::Mongoid
        require 'r8/model/default_scope/mongoid_scope'
        include R8::Model::DefaultScope::MongoidScope
      end

      module ClassMethods

        # index
        # @PARAMS
        #   - page: N ( default 1 )
        #   - per : N ( default 1 )
        def index_scope pms
          os = scoped
          return os.page(pms[:page]).per(pms[:per])
        end
        

      end

    end
  end
end
