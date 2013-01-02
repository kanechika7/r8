# coding: UTF-8
module R8
  module Model
    module DefaultScope
      module ActiveRecordScope
        extend ActiveSupport::Concern
        included do

          kls = self #parent
   
          # fields scope
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

          # relations scope
          kls.reflections.each_pair do |k,v|
            kls.scope "ins_#{k}",include: k
          end

          # condition
          # @PARAMS:
          #   ceq_<field>  ：equal field     （ field == :val ）
          #   ceq_<fields> ：equal fields    （ field in (:val) ）
          #   cmc_<field>  ：match field     （ field =~ :val ）
          #   cneq_<field> ：not equal field （ field != :val ）
          #   cneq_<fields>：not equal fields（ field not in (:val) ）
          #   lte_<field>  ：less than equal field   （ field <= :val ）
          #   lt_<field>   ：less than field         （ field < :val ）
          #   gte_<field>  ：grater than equal field （ field >= :val ）
          #   gt_<field>   ：grater than field       （ field > :val ）
          kls.scope :condition_scope ,->(pms){
            os = scoped
            pms.each_pair do |k,v|
              case k.to_s
              when /^cmc\_(.*)/
                os = os.where(arel_table[$1.to_sym].matches("%#{v}%")) unless v.blank?
              when /^ceq\_(.*)/
                unless v.blank?
                  plu = $1.pluralize
                  if plu==$1
                    os = os.where("#{kls.table_name}.#{$1.singularize} in (?)",v.split(','))
                  else
                    os = os.where($1=>v)
                  end
                end
              when /^cneq\_(.*)/
                unless v.blank?
                  plu = $1.pluralize
                  if plu==$1
                    os = os.where("#{kls.table_name}.#{$1.singularize} not in (?)",v.split(','))
                  else
                    os = os.where("#{kls.table_name}.#{$1} != ?",v)
                  end
                end
              when /^lte\_(.*)/
                os = os.where("#{kls.table_name}.#{$1} <= ?",v) unless v.blank?
              when /^lt\_(.*)/
                os = os.where("#{kls.table_name}.#{$1} < ?",v) unless v.blank?
              when /^gte\_(.*)/
                os = os.where("#{kls.table_name}.#{$1} >= ?",v) unless v.blank?
              when /^gt\_(.*)/
                os = os.where("#{kls.table_name}.#{$1} > ?",v) unless v.blank?
              end

            end
            return os
          }

          # include
          # @PARAMS:
          #   in：<relation>,<relation>,<relation>
          kls.scope :in_scope ,->(pms){
            os = scoped
            pms.each_pair do |k,v|
              case k.to_s
              when 'in'
                unless v.blank?
                  v.split(",").each{|rel| os = os.send("ins_#{rel}".to_s) }
                end
              end
            end
            return os
          }

          # order
          # @PARAMS:
          #   o：od_<field> or oa_<field>
          kls.scope :order_scope ,->(pms){
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

          # for API methods
          # @HOWTO:
          #
          #   class Api
          #     class V1::ItemsController < V1
          #
          #       # GET ./items.json
          #       def find_index
          #         # default setting
          #         params.reverse_merge!({
          #           :o   => 'od_created_at',
          #         　:in  => '',
          #         　:mes => '',
          #         　:p   => 1,
          #         　:pp  => 10 })
          #         # get datas
          #         @items = Item.api_records(params)
          #       end
          #
          #       def index
          #         respond_index(@items,{
          #           t_json: Proc.new( render json: Item.api_records_to_json(@items,params) )
          #         })
          #       end
          #
          #
          #       # GET ./item/:id.json
          #       def find_one
          #         # default parameters
          #         params.reverse_merge!({
          #           :in  => '',
          #           :mes => '' })
          #         # get data
          #         @item = Item.api_record(params).first
          #       end
          #
          #       def show
          #         respond_show(@item,{
          #           t_json: Proc.new{ render json: Item.api_record_to_json(@item,params) }
          #         })
          #       end
          #

          # get records for api
          def api_records pms
            os = scoped
            os = os.condition_scope(pms)          # conditions
            os = os.in_scope(pms)                 # includes
            os = os.order_scope(pms)              # orders
            return os.page(pms[:p]).per(pms[:pp]) # pagination
          end

          # records to json for api
          def api_records_to_json objs, pms
            # setting
            opts = { :api => 'v1' }
            opts[:methods] = pms[:mes].split(',') unless pms[:mes].blank?
            opts[:include] = pms[:in].split(',') unless pms[:in].blank?
            # get
            json = objs.as_json(opts)
            return { # data
                     :data  => json,
                     # base information
                     :o     => pms[:o],          # order
                     :in    => pms[:in],         # includes
                     :mes   => pms[:mes],        # methods
                     :p     => pms[:p].to_i,     # page
                     :pp    => pms[:pp].to_i,    # per_page
                     :lp    => objs.total_pages, # total pages
                     :total => objs.total_count  # total count
                   }
          end

          # get record for api
          def api_record pms
            os = scoped
            os = os.where(id: pms[:id])
            os = os.in_scope(pms)         # includes系
            return os
          end

          # record to json for api
          def api_record_to_json obj, pms
            # setting
            opts = { :api => 'v1' }
            opts[:methods] = pms[:mes].split(',') unless pms[:mes].blank?
            opts[:include] = pms[:in].split(',') unless pms[:in].blank?
            # 取得
            json = obj.as_json(opts)
            return json 
          end

        end

      end
    end
  end
end
