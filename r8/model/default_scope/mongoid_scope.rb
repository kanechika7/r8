# coding: UTF-8

module R8
  module Model
    module DefaultScope
      module MongoidScope
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


            # _position or _at or _count order
            # @PATTERN
            #  - ***_position or ***_at or ***_count
            # @HOWTO
            #   - od_******: order desc
            #   - oa_******: order asc
            if k.to_s=~/_(position|at|count|point|pv)$/
              scope "od_#{k}" ,order_by([k,:desc])
              scope "oa_#{k}" ,order_by([k,:asc ])
            end

          end
      
        end
      end
    end
  end
end
