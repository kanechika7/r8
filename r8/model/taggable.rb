# coding: UTF-8

#
# SETTING
#
#  $ vim app/models/item.rb
#
#  class Item
#
#    include R8::Model::Taggable
#    setting_tags [:area_tags]
#
# HOWTO 
#
#  rails> item           = Item.new
#  rails> item.area_tags = "AA,BB"
#  rails> item.area_tags_array # => ["AA","BB"]
#  rails> item.save
#
#  rails> Item.area_tags # => ["AA","BB"]
#  rails> Item.area_tagged_with("AA").size # => 1
#

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

            t_name   = "#{ts_name.to_s}".singularize
            pt_name  = "#{t_name}ged"
            tas_name = "#{ts_name}_array"

            define_singleton_method "enable_#{ts_name}_index!" do
              instance_variable_set("@do_#{ts_name}_index",true)
            end

            # STRUCTURE
            class_eval do

              field tas_name, type: Array, default: []
              index [[tas_name,Mongo::ASCENDING]]

              after_save do |document|
                if document.send("#{tas_name}_changed")
                  document.class.send("save_#{ts_name}_index!")
                  document.send("#{tas_name}_changed=",false)
                end
              end

              attr_accessor "#{tas_name}_changed"
              send("enable_#{ts_name}_index!")

            end


            # CLASS METHODS

            define_singleton_method "#{pt_name}_with" do |tag|
              self.any_in(tas_name => [tag])
            end

            define_singleton_method "#{pt_name}_with_all" do |*tags|
              self.all_in(tas_name => tags.flatten)
            end

            define_singleton_method "#{pt_name}_with_any" do |*tags|
              self.any_in(tas_name => tags.flatten)
            end

            define_singleton_method ts_name do
              send("#{ts_name}_index_collection").master.find.to_a.map{ |r| r["_id"] }
            end

            define_singleton_method "#{ts_name}_with_weight" do
              send("#{ts_name}_index_collection").master.find.to_a.map{ |r| [r["_id"], r["value"]] }
            end

            define_singleton_method "disable_#{ts_name}_index!" do
              instance_variable_set("@do_#{ts_name}_index",false)
            end


            define_singleton_method "#{ts_name}_separator" do |*separators|
              separator = (separators.empty?) ? nil : separators[0]
              instance_variable_set("@#{ts_name}_separator",separator) if separator
              instance_variable_get("@#{ts_name}_separator") || ','
            end

            define_singleton_method "#{ts_name}_index_collection_name" do
              "#{collection_name}_#{ts_name}_index"
            end

            define_singleton_method "#{ts_name}_index_collection" do
              return class_variable_get("@@#{ts_name}_index_collection") if class_variable_defined?("@@#{ts_name}_index_collection")
              class_variable_set("@@#{ts_name}_index_collection",Mongoid::Collection.new(self, send("#{ts_name}_index_collection_name")))
            end

            define_singleton_method "save_#{ts_name}_index!" do
              return unless instance_variable_get("@do_#{ts_name}_index")

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



            # INSTANTCE METHODS
            define_method ts_name do
              (send(tas_name) || []).join(self.class.send("#{ts_name}_separator"))
            end

            define_method "#{ts_name}=" do |ts|
              self.send("#{tas_name}=",ts.split(self.class.send("#{ts_name}_separator")).map(&:strip).reject(&:blank?))
              instance_variable_set("@#{tas_name}_changed",true)
            end

          end



        end

      end

    end
  end
end
