# coding: UTF-8
module R8
  # helper
  require File.join(File.dirname(__FILE__), 'r8/helper')

  # controllers
  require File.join(File.dirname(__FILE__), 'r8/controller')
  
  # models
  require File.join(File.dirname(__FILE__), 'r8/model')
  require File.join(File.dirname(__FILE__), 'r8/model/default_scope')
  require File.join(File.dirname(__FILE__), 'r8/model/under_relation')
  require File.join(File.dirname(__FILE__), 'r8/model/by_resque')

  require File.join(File.dirname(__FILE__), 'r8/model/holder')
end
