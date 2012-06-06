INSTALL
================================

  $ cd RAILS_ROOT/lib
  $ git clone git@github.com:kanechika7/r8.git

  $ config/application.rb

    module RailsApp
      class Application < Rails::Application

      config.autoload_paths += %W(#{config.root}/lib/r8)  



SETTING
================================

MODEL
--------------------------------

  $ vim app/models/item.rb

    class Item
      include R8::Model
    end

  $ vim app/model/item/scope.rb

    class Item
      module scope
        include R8::Model::DefaultScope
      end
    end

  $ vim app/model/item/aktion.rb

    class Item
      module Aktion
        include R8::Model::ByResque
        by_resques [:abc]

        def abc
          puts "abc"
        end

      end
    end
