# coding: UTF-8
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

          # condition
          # @PARAMS:
          #   ceq_<field>  ： equal（ field == :val ）
          #   cmc_<field>  ： match（ field =~ :val ）
          #   cneq_<fields>：not equal（ field != :val ）
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

          # order
          # @PARAMS:
          #   o：od_<field> or oa_<field>
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

          # for API methods
          # @HOWTO:
          #
          #   class Api
          #     class V1::ItemsController < V1
          #
          #       def find_index
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

          # get records for api
          def api_records pms
            os = scoped
            os = os.condition_scope(pms)          # conditions
            os = os.order_scope(pms)              # orders
            return os.page(pms[:p]).per(pms[:pp]) # pagination
          end

          # records to json for api
          def api_records_to_json objs, pms
            # setting
            opts = { :api => 'v1' }
            opts[:methods] = pms[:mes].split(',') unless pms[:mes].blank?
            opts[:includes] = pms[:in].split(',') unless pms[:in].blank?
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

        end

      end
    end
  end
end
