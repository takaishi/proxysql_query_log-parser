module ProxysqlQueryLogParser
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
        
        q.thread_id = read_encoded_length(io)
        username_len = read_encoded_length(io)
        q.username = read_encoded_string(io, username_len)
        schemaname_len = read_encoded_length(io)
        q.schemaname = read_encoded_string(io, schemaname_len)
        client_len = read_encoded_length(io)
        q.client = read_encoded_string(io, client_len)
        q.hid = read_encoded_length(io)
        server_len = read_encoded_length(io)
        q.server = read_encoded_string(io, server_len)
        
        io.read(1).unpack('C')
        q.start_time = io.read(8).unpack('Q*')[0]
        io.read(1).unpack('C')
        q.end_time = io.read(8).unpack('Q*')[0]
        
        io.read(1).unpack('C')
        q.digest = "0x#{io.read(8).unpack('I*').map{|n| sprintf("%X", n)}.join("")}"
        
        query_len = read_encoded_length(io)
        q.query = read_encoded_string(io, query_len)
        queries << q
      end
      queries.each do |query|
        query.print
      end
    end

    private

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

