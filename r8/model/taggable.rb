# coding: UTF-8

module R8
  module Model
    module Taggable
      extend ActiveSupport::Concern

      module ClassMethods
 
        def setting_tags tts

          tts.each do |ts_name|

            # Define Name
            # ex.
            #   - t_name   : 'tag'
            #   - pt_name  : 'tagged'
            #   - ts_name  : 'tags'
            #   - tas_name : 'tags_array'

            t_name   = ts_name.singularize
            pt_name  = "#{t_name}ged"
            tas_name = "#{ts_name}_array"


            # STRUCTURE
            class_eval do

              field tas_name, type: Array, default: []
              index [[tas_name,Mongo::ASCENDING]]

              after_save do |document|
                if document.send("#{tas_name}_changed")
                  document.class.send("save_#{t_name}_index!")
                  document.send("#{tas_name}_changed=",false)
                end
              end

              attr_accessor "#{tas_name}_changed"
              send("enable_#{t_name}_index!")

            end


            # CLASS METHODS
            class_eval do

              define_method "#{pt_name}_with" do |tag|
                self.any_in(tas_name => [tag])
              end

              define_method "#{pt_name}_with_all" do |*tags|
                self.all_in(tas_name => tags.flatten)
              end

              define_method "#{pt_name}_with_any" do |*tags|
                self.any_in(tas_name => tags.flatten)
              end

              define_method ts_name do
                send("#{ts_name}_index_collection").master.find.to_a.map{ |r| r["_id"] }
              end

              define_method "#{ts_name}_with_weight" do
                send("#{ts_name}_index_collection").master.find.to_a.map{ |r| [r["_id"], r["value"]] }
              end

              define_method "disable_#{ts_name}_index!" do
                instance_variable_set("@do_#{ts_name}_index",false)
              end

              define_method "enable_#{ts_name}_index!" do
                instance_variable_set("@do_#{ts_name}_index",true)
              end

              define_method "#{ts_name}_separator" do |separator=nil|
                instance_variable_set("@#{ts_name}_separator",separator) if separator
                eval("@#{ts_name}_separator") || ','
              end

              define_method "#{ts_name}_index_collection_name" do
                "#{collection_name}_#{ts_name}_index"
              end

              define_method "#{ts_name}_index_collection" do
                eval("@@#{ts_name}_index_collection") ||= Mongoid::Collection.new(self, send("#{ts_name}_index_collection_name"))
              end

              define_method "save_#{ts_name}_index!" do
                return unless eval("@do_#{ts_name}_index")

                map = "function() {
                  if (!this.#{tas_name}) {
                    return;
                  }
                  for (index in this.#{tas_name}) {
                    emit(this.#{tas_name}[index], 1);
                  }
                }"

                reduce = "function(previous, current) {
                  var count = 0;

                  for (index in current) {
                    count += current[index]
                  }

                  return count;
                }"

                self.collection.master.map_reduce(map, reduce, :out => send("#{ts_name}_index_collection_name"))
              end

            end


            # INSTANTCE METHODS
            define_method ts_name do
              (send("tas_name") || []).join(self.class.send("#{ts_name}_separator"))
            end

            define_method "#{ts_name}=" do |tags|
              self.send("tas_name=",send("ts_name").split(self.class.send("#{ts_name}_separator")).map(&:strip).reject(&:blank?))
              instance_variable_set("@#{tas_name}_changed",true)
            end


          end

        end

      end

    end
  end
end
