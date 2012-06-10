# coding: UTF-8

# よく使うScope
module R8
  module Model
    module DefaultScope
      extend ActiveSupport::Concern
      included do
 
        self.fields.each_pair do |k,v|

          # _flg filter
          # @PATTERN
          #   - ***_flg
          # @HOWTO
          #   - t_***_flg: ***_flg is true
          #   - f_***_flg: ***_flg is false
          if k.to_s=~/_flg$/
            scope "t_#{k}" ,where(k=>true)
            scope "f_#{k}" ,where(k=>false)
          end


          # _position or _at order
          # @PATTERN
          #  - ***_position or ***_at
          # @HOWTO
          #   - od_******: order desc
          #   - oa_******: order asc
          if k.to_s=~/_(position|at)$/
            scope "od_#{k}" ,order_by([k,:desc])
            scope "oa_#{k}" ,order_by([k,:asc ])
          end


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
