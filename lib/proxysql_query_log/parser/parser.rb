module ProxysqlQueryLog
  class Parser
    def load_file(path)
      io = File.open(path)
      read(io)
    end

    def read(io)
      queries = []
      
      while true
        raw_total_bytes = io.read(8)
        break unless raw_total_bytes
        queries << parse(io)
      end
      queries
    end

    def parse(io)
      q = Query.new
      if io.read(1).unpack1('C') == 0
        q.thread_id = parse_thread_id(io)
        q.username = parse_username(io)
        q.schema_name = parse_schema_name(io)
        q.client = parse_client(io)
        q.hid = parse_hid(io)
        unless q.hid == 18446744073709551615
          q.server = parse_server(io)
        end
        q.start_time = parse_start_time(io)
        q.end_time = parse_end_time(io)
        q.digest = parse_digest(io)
        q.query = parse_query(io)
      end
      q
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
      io.read(8).unpack1('Q*')
    end

    def parse_end_time(io)
      io.read(1).unpack('C')
      io.read(8).unpack1('Q*')
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
      buf = io.read(1).unpack1('C')
      len = mysql_decode_length(buf)
      unless len == 0
        buf2 = case len
               when 1
                 buf
               when 3
                 (io.read(len-1) + ("\x00" * (9 - len))).unpack1('Q*')
               when 9
                 io.read(8).unpack1('Q*')
               end
        return buf2
      end
    end
    
    def read_encoded_string(io, len)
      io.read(len).unpack1('a*')
    end
  end
end

