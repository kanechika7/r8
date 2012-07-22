# ResqueのWorkerに共通するクラス 
# @author KURUMA
# @since  1.5.0
class ResqueWorker
  @queue = :default

  # ログの出力（クラスメソッド版）
  # @author KURUMA
  # @since  1.5.0
  def self.log(txt="")
    path = File.expand_path("log/resque.log", Rails.root.to_s)
    File.open(path, 'a'){|f| f.puts txt }
  end

  # ログの出力（インスタンスメソッド版）
  # @author KURUMA
  # @since  1.5.0
  def log(txt="")
    self.class.log txt
  end

  # workerで実行されるメソッド
  # ログ出力だけはここでやっておく
  # @author KURUMA
  # @since  1.5.0
  def self.perform(arg)
    log arg.inspect
  end

end
