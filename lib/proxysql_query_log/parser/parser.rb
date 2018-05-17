module ProxysqlQueryLog
  class Parser
    def load_file(path)
      io = File.open(path)
      parse(io)
    end

    def parse(io)
      queries = []
      
      while true
        raw_total_bytes = io.read(1)
        break unless raw_total_bytes
        total_bytes = raw_total_bytes.unpack('C')[0]
        # io.read(7)
        io.seek(7, IO::SEEK_CUR)

        raw = io.read(total_bytes)
        query_io = StringIO.new(raw, 'r+')
        q = Query.new

        if query_io.read(1).unpack('C')[0] == 0
          q.thread_id = parse_thread_id(query_io)
          q.username = parse_username(query_io)
          q.schema_name = parse_schema_name(query_io)
          q.client = parse_client(query_io)
          q.hid = parse_hid(query_io)
          q.server = parse_server(query_io)
          q.start_time = parse_start_time(query_io)
          q.end_time = parse_end_time(query_io)
          q.digest = parse_digest(query_io)
          q.query = parse_query(query_io)
        end
        queries << q
      end
      queries
    end

    private

    def parse_thread_id(io)
      read_encoded_length(io)
    end

    def parse_username(io)
      read_encoded_string(io,read_encoded_length(io))
    end

    def parse_schema_name(io)
      read_encoded_string(io, read_encoded_length(io))
    end

    def parse_client(io)
      read_encoded_string(io, read_encoded_length(io))
    end

    def parse_hid(io)
      read_encoded_length(io)
    end

    def parse_server(io)
      read_encoded_string(io,read_encoded_length(io))
    end

    def parse_start_time(io)
      io.read(1).unpack('C')
      io.read(8).unpack('Q*')[0]
    end

    def parse_end_time(io)
      io.read(1).unpack('C')
      io.read(8).unpack('Q*')[0]
    end

    def parse_digest(io)
      io.read(1).unpack('C')
      "0x#{io.read(8).unpack('I*').map{|n| sprintf("%X", n)}.join("")}"
    end

    def parse_query(io)
      query_len = read_encoded_length(io)
      read_encoded_string(io, query_len)
    end

    def mysql_decode_length(buf)
      case
        when buf <= 0xfb
          1
        when buf == 0xfc
          3
        when buf == 0xfd
          4
        when buf == 0xfe
          9
        else
          0
      end
    end

    def read_encoded_length(io)
      buf = io.read(1).unpack('C')
      len = mysql_decode_length(buf[0])
      unless len == 0
        buf2 = io.read(len-1).unpack('C*')
        buf.concat(buf2)
        return buf == 0 ? 0 : buf[0]
      end
    end
    
    def read_encoded_string(io, len)
      io.read(len).unpack('a*')[0]
    end
  end
end

