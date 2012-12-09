# coding: UTF-8
#

module R8
  module Model
    module DefaultScope
      module ActiveRecordScope
        extend ActiveSupport::Concern
        included do

          kls = self #parent
   
          kls.attribute_names.each do |k|

            # _flg filter
            # @PATTERN
            #   - ***_flg
            # @HOWTO
            #   - t_***_flg: ***_flg is true
            #   - f_***_flg: ***_flg is false
            if k.to_s=~/_flg$/
              kls.scope "t_#{k}" ,where(k=>true)
              kls.scope "f_#{k}" ,where(k=>false)
            end


            # _position or _at or _count order
            # @PATTERN
            #  - ***_position or ***_at or ***_count
            # @HOWTO
            #   - od_******: order desc
            #   - oa_******: order asc
            if k.to_s=~/_(position|at|count|point|pv)$/
              kls.scope "od_#{k}" ,order: "#{k} DESC"
              kls.scope "oa_#{k}" ,order: "#{k} ASC"
            end

          end
      
        end

      end
    end
  end
end