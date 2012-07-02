# coding: UTF-8

#
# SETTING
# 
#   class Item
#     include R8::Model::SingleValidMessage
#
#
# HOW TO
#
#   = @item.single_valid_message(:name)  
#

module R8
  module Model
    module SingleValidMessage
      extend ActiveSupport::Concern

      module InstanceMethods

        def single_valid_message field
          return "" if errors.empty? or errors[field].empty?
          unsco_clazz = self.class.to_s.underscore
          messages = errors[field].map{|msg| "<li>"+I18n.t("activerecord.attributes.#{unsco_clazz}.#{field}")+msg+"</li>" }.uniq.join
          html = <<-HTML
            <div class='error_explanation'>
              <ul>#{messages}</ul>
            </div>
          HTML
          html.html_safe
        end 

      end

    end
  end
end
