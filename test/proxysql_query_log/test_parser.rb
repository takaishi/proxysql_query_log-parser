require 'test/unit'
require 'proxysql_query_log/parser'

class TestSample < Test::Unit::TestCase
  class << self
    # テスト群の実行前に呼ばれる．変な初期化トリックがいらなくなる
    def startup
      p :_startup
    end

    # テスト群の実行後に呼ばれる
    def shutdown
      p :_shutdown
    end
  end

  TMP_DIR = File.dirname(__FILE__) + '/../tmp/proxysql_query_log'
  # 毎回テスト実行前に呼ばれる
  def setup
    p :setup
  end

  # テストがpassedになっている場合に，テスト実行後に呼ばれる．テスト後の状態確認とかに使える
  def cleanup
    p :cleanup
  end

  # 毎回テスト実行後に呼ばれる
  def teardown
    p :treadown
  end

  def test_singlefile
    File.open("#{TMP_DIR}/query_log", 'w+b') do |f|
      p f
      write_record(f)
      f.seek(0)
      parser = ProxysqlQueryLog::Parser.new
      q = parser.read(f)[0]

      # assert_equal(true, events.length > 0)
      # assert_equal(1, 1)
      assert_equal(9, q.thread_id)
      assert_equal('root', q.username)
      assert_equal('alpaca', q.schema_name)
      assert_equal('127.0.0.1:34612', q.client)
      assert_equal(0, q.hid)
      assert_equal('127.0.0.1:3306', q.server)
      assert_equal(1525944256367381, q.start_time)
      assert_equal(1525944256367837, q.end_time)
      assert_equal('0xD69C6B36F32D2EAE', q.digest)
      assert_equal('SELECT * FROM test', q.query)
    end
  end

  def write_record(f)
    q = ProxysqlQueryLog::Query.create(9, 'root','alpaca','127.0.0.1:34612',0, '127.0.0.1:3306', 1525944256367381,1525944256367837, '0xD69C6B36F32D2EAE','SELECT * FROM test')
    buf = ''
    io = StringIO.new(buf)

    io.write([0].pack('C*'))
    io.write([q.thread_id].pack('C*'))

    io.write([q.username.size].pack('C*'))
    io.write(q.username)

    io.write([q.schema_name.size].pack('C*'))
    io.write(q.schema_name)

    io.write([q.client.size].pack('C*'))
    io.write(q.client)

    io.write([q.hid].pack('C*'))

    io.write([q.server.size].pack('C*'))
    io.write(q.server)

    io.write([0xfe].pack('C*'))
    io.write([q.start_time].pack('Q*'))

    io.write([0xfe].pack('C*'))
    io.write([q.end_time].pack('Q*'))

    io.write([0xfe].pack('C*'))
    io.write(q.digest.gsub(/0x/, '').scan(/.{1,8}/).map{|s| s.hex}.pack('I*'))

    io.write([q.query.size].pack('C*'))
    io.write(q.query)

    f.write([q.total_length, 0, 0, 0, 0, 0, 0, 0].pack('C*'))
    f.write(buf)
  end
end