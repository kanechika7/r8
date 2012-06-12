# coding: UTF-8
#
# リレーションがあるオブジェクトのattributesを_（アンダー）で取得する
# 
# SETTING
#
#  class Item 
#    include R8::Model::UnderRelation
#    under_relations({ abc: Abc })
#
# 
# USE
#
#   $ item.abc_name
#
#
module R8
  module Model
    module UnderRelation
      extend ActiveSupport::Concern
      module ClassMethods

        def under_relations hash
          hash.each_pair do |ref,clazz|
            clazz.fields.each_pair do |k,v|
              define_method "#{ref}_#{k}" do
                if obj = send(ref)
                  obj.send(k)
                end 
              end 
            end 
          end 
        end

      end
    end
  end
end
