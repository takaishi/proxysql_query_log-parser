require 'test/unit'
require 'helper'
require 'tempfile'
require 'proxysql_query_log/parser'

class TestSample < Test::Unit::TestCase
  TMP_DIR = File.dirname(__FILE__) + '/../tmp/proxysql_query_log'

  def test_singlefile
    File.open("#{TMP_DIR}/query_log", 'w+b') do |f|
      param = {thread_id: 9, username: 'root', schema_name: 'alpaca', client: '127.0.0.1:34612', hid: 0, server: '127.0.0.1:3306', start_time: 1525944256367381, end_time: 1525944256367837, digest: '0xD69C6B36F32D2EAE', query: 'SELECT * FROM test'}
      write_record(f, param)
      f.seek(0)
      parser = ProxysqlQueryLog::Parser.new
      q = parser.read(f)[0]

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

  def test_read_encode_length
    parser = ProxysqlQueryLog::Parser.new

    [
        # <= 0xfb
        {input: "\xC8", expected: 200},
        {input: "\xFB", expected: 251},

        # == 0xfc
        {input: "\xFC\x9A\x01", expected: 410},

        # == 0xfe
        {input: "\xFE\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF", expected: 18446744073709551615},

    ].each do |data|
      input = data[:input]
      expected = data[:expected]
      Tempfile.open('proxysql_querylog'){|fp|
        fp.binmode
        fp.write(input.unpack('C*').pack('C*'))
        fp.seek(0)
        assert_equal(expected, parser.send(:read_encoded_length, fp))
      }
    end
  end

  def write_record(f, param)
    q = ProxysqlQueryLog::Query.create(param[:thread_id], param[:username], param[:schema_name], param[:client], param[:hid], param[:server], param[:start_time], param[:end_time], param[:digest], param[:query])
    f.write([total_length(q), 0, 0, 0, 0, 0, 0, 0].pack('C*'))
    f.write(to_binary(q))
  end
end
