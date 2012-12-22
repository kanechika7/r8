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


            # od_ or oa_
            # @HOWTO
            #   - od_<field>: order desc
            #   - os_<field>: order desc
            kls.scope "od_#{k}" ,order: "#{k} DESC"
            kls.scope "oa_#{k}" ,order: "#{k} ASC"

          end

          # 絞り込み条件
          kls.scope :condition_scope ,->(pms){
            os = scoped
            pms.each_pair do |k,v|
              case k.to_s
              when /^cmc\_(.*)/
                os = os.where(arel_table[$1.to_sym].matches("%#{v}%")) unless v.blank?
              when /^ceq\_(.*)/
                os = os.where($1=>v) unless v.blank?
              when /^cneq\_(.*)/
                os = os.where("#{kls.table_name}.#{$1.singularize} not in (?)",v.split(',')) unless v.blank?
              end
            end
            return os
          }

          # オーダー系
          kls.scope :order_scope ,lambda { |pms|
            os = scoped
            pms.each_pair do |k,v|
              case k.to_s
              when 'o'
                os = os.send(v.to_sym) unless v.blank?
              end
            end
            return os
          }
      
        end

        module ClassMethods

          def api_records pms
            os = scoped
            os = os.condition_scope(pms)          # 絞り込み条件系
            os = os.order_scope(pms)              # オーダー系
            return os.page(pms[:p]).per(pms[:pp]) # ページネーション
          end

          def api_records_to_json objs, pms
            # setting
            opts = { :api => 'v1' }
            opts[:methods] = pms[:mes].split(',') unless pms[:mes].blank?
            opts[:includes] = pms[:in].split(',') unless pms[:in].blank?
            # 取得
            json = objs.as_json(opts)
            return { # data
                     :data  => json,
                     # 基本情報
                     :o     => pms[:o],
                     :in    => pms[:in],
                     :mes   => pms[:mes],
                     :p     => pms[:p].to_i,
                     :pp    => pms[:pp].to_i,
                     :lp    => objs.total_pages,
                     :total => objs.total_count }
          end

        end

      end
    end
  end
end
