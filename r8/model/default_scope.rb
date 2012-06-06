# coding: UTF-8

# よく使うScope
module R8
  module Model
    module DefaultScope
      extend ActiveSupport::Concern
      included do
      
        # Order
        # @PATERN
        #  - created_at, updated_at
        # @HOWTO
        #   - od_******: order desc
        #   - oa_******: order asc
        [:created_at,:updated_at].each do |o|
          scope "od_#{o}" ,order_by([o,:desc])
          scope "oa_#{o}" ,order_by([o,:asc ])
        end

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
