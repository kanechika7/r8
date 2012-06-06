
workers
==============================================================
・バックグラウンド処理は呼び出しているファイルに記述する
・呼び出すメソッド名 ***********_by_resque
・ByResque モジュールの作成（上記をメタプログラミング）



・メタプログラミング

  include R8::ByResque
  by_resques [:create_or_add_author_and_publisher,
              *,*,*]

  # -> create_or_add_author_and_publisher_by_resque が作成され下記を呼び出す

  def create_or_add_author_and_publisher
  end


・研究
  - 著者と出版社の追加を裏側で行おうと思った

  # bgで処理させるように指示するメソッド
  def create_or_add_author_and_publisher_by_resque
    Resque.enqueue(CreateOrAddAuthorAndPublisher,id)
  end

  # 作成メソッド
  def create_or_add_author_and_publisher
  end


class CreateOrAddAuthorAndPublisher < ResqueWorker
  @queue = :create_or_and_author_and_publisher_server

  def self.perform book_id
    Book.find(book_id).create_or_add_author_and_publisher
  end
end

