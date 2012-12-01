# coding: UTF-8
class ObjectMethodsWorker < ResqueWorker
  @queue = :object_methods_server

  # @object.method,...
  # params: [[klass_name,id,method_name],..]
  def self.perform array
    array.each do |arr|
      obj = arr[0].constantize.find(arr[1])
      obj.send(arr[2])
    end
  end
end
