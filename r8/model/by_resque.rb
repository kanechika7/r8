# coding: UTF-8
#
# インスタンスメソッドをバックグラウンド処理させる
#
# 
# SETTING
#
#  class Item 
#    include R8::Model::ByResque
#    by_resques [:abc]
# 
#    def abc
#      path = File.expand_path("log/resque.log", Rails.root)
#      File.open(path, 'a'){|f| f.puts "Hello abc!" }
#    end
#
#  end
#
#
# HOW TO
#
#  # resque server start
#  $ QUEUE=* VVERBOSE=true be rake environment resque:work
#
#  # バックグラウンド処理
#  $ obj = Obj.find(:id)
#  $ obj.abc
#    -> Hello abc!
#  $ obj.abc_by_resque
#    -> Hello abc!（バックグラウンド）
#
#

require File.join(File.dirname(__FILE__),'../workers/resque_worker.rb')
module R8
  module Model
    module ByResque
      extend ActiveSupport::Concern
      module ClassMethods

        def by_resques ms
          ms.each do |m|
            define_method "#{m}_by_resque" do #|*args|
              Resque.enqueue(::ResqueWorker::ByResqueServer,self.class.to_s,id,m) #,args)
            end
          end
        end

      end
    end
  end
end

class ByResqueServer < ResqueWorker
  @queue = :by_resque_server

  def self.perform klass_name,id,method_name #,args
    obj = klass_name.constantize.find(id)
    obj.send(method_name) #,args)
  end
end


