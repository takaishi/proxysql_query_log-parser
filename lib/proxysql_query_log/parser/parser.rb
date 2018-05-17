module ProxysqlQueryLog
  class Parser
    def load_file(path)
      io = File.open(path)
      parse(io)
    end

    def parse(io)
      queries = []
      
      while true
        io.read(8)
        s = io.read(1)
        break unless s
        q = Query.new
        s.unpack('b')
        
        q.thread_id = parse_thread_id(io)
        q.username = parse_username(io)
        q.schema_name = parse_schema_name(io)
        q.client = parse_client(io)
        q.hid = parse_hid(io)
        q.server = parse_server(io)
        q.start_time = parse_start_time(io)
        q.end_time = parse_end_time(io)
        q.digest = parse_digest(io)
        q.query = parse_query(io)

        queries << q
      end
      queries
    end

    private

    def parse_thread_id(io)
      read_encoded_length(io)
    end

    def parse_username(io)
      username_len = read_encoded_length(io)
      read_encoded_string(io, username_len)
    end

    def parse_schema_name(io)
      schema_name_len = read_encoded_length(io)
      read_encoded_string(io, schema_name_len)
    end

    def parse_client(io)
      client_len = read_encoded_length(io)
      read_encoded_string(io, client_len)
    end

    def parse_hid(io)
      read_encoded_length(io)
    end

    def parse_server(io)
      server_len = read_encoded_length(io)
      read_encoded_string(io, server_len)
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
      if buf <= 251
        return 1
      elsif buf == 252
        return 3
      elsif buf == 253
        return 4
      elsif buf == 254
        return 9
      else
        return 0
      end
    end
    
    def mysql_decode_length_2(buf, len)
      if buf[0] <= 251
        return buf[0]
      elsif buf[0] == 252
        return buf[0]
      elsif buf[0] == 253
        return buf[0]
      elsif buf[0] == 254
        return buf[0]
      else
        return 0
      end
    end
    
    def read_encoded_length(io)
      buf = io.read(1).unpack('C')
      len = mysql_decode_length(buf[0])
      unless len == 0
        buf2 = io.read(len-1).unpack('C*')
        buf.concat(buf2)
        return mysql_decode_length_2(buf, len)
      end
    end
    
    def read_encoded_string(io, len)
      io.read(len).unpack('a*')[0]
    end
  end
end

