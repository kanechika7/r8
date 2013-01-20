# coding: UTF-8
# 
# SETTING
#
# $ vim app/controllers/application_controller.rb
# class ApplicationController
#
#   include R8::Controller::Error
#   define_errors R8RuntimeError: 500, R8NotFound: 404
#
#   # Call the response method when raise an exception
#   #   for ActiveRecord
#   rescue_from ActiveRecord::RecordNotFound, with: respond_404
#   #   for Mongoid
#   rescue_from Mongoid::Errors::DocumentNotFound, BSON::InvalidObjectId, with: :respond_404
#
module R8
  module Controller
    module Error
      extend ActiveSupport::Concern

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def define_errors statuses, superclass = StandardError
          statuses.each do |class_name, code|
            respond = :"respond_#{code}"

            define_error_class class_name, superclass
            define_respond_method respond, code

            # R8 error maps to respond method
            rescue_from "#{class_name}".constantize, with: respond
          end
        end

        def define_error_class class_name, superclass = StandardError
          return if Object.const_defined?(class_name)
          Object.const_set(class_name, Class.new(superclass))
        end

        # Define "respond_#{code}" method
        def define_respond_method name, code
          return if method_defined?(name)
          define_method name do |e = nil|
            render status: code, file: "#{Rails.root}/public/#{code}.html", layout: false and return
          end
        end
      end

    end
  end
end
