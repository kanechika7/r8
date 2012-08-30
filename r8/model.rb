# coding: UTF-8

# 
# How To
#
# 1. Setting
# $ vim app/models/item.rb
# class Item 
#   include R8::Model
#
#
# 2. Directory
# /item
#   |- klass.rb
#   |- structure.rb
#   |- feature.rb
#   |- output.rb
#   |- aktion.rb
#   |- call_back.rb
#   |- vendor.rb
#   |- original.rb         
#


module R8
  module Model
    extend ActiveSupport::Concern

    included do

      klass_name    = self.to_s

      # include
      include "#{klass_name}::Klass".constantize     if exist?("klass.rb")
      include "#{klass_name}::Structure".constantize if exist?("structure.rb")
      include "#{klass_name}::Feature".constantize   if exist?("feature.rb")
      include "#{klass_name}::Output".constantize    if exist?("output.rb")
      include "#{klass_name}::Scope".constantize     if exist?("scope.rb")
      include "#{klass_name}::Aktion".constantize    if exist?("aktion.rb")
      include "#{klass_name}::CallBack".constantize  if exist?("call_back.rb")
      include "#{klass_name}::Vendor".constantize    if exist?("vendor.rb")
      include "#{klass_name}::Original".constantize  if exist?("original.rb")
      include "#{klass_name}::Workers".constantize   if exist?("workers.rb")
    end

    module ClassMethods

      # ファイルの存在を確かめる
      # @author Nozomu Kanechika
      # @since gw
      def exist? file
        File.exist?( File.join( Rails.root, "app/models", self.to_s.underscore, file ) )
      end

    end


  end
end
