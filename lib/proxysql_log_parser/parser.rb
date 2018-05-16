module ProxysqlLogParser
  class Parser
    def parse(path)
      io = File.open(path)
      
      while true
        io.read(8)
        s = io.read(1)
        break unless s
        s.unpack('b')
        
        thread_id = read_encoded_length(io)
        username_len = read_encoded_length(io)
        username = read_encoded_string(io, username_len)
        schemaname_len = read_encoded_length(io)
        schemaname = read_encoded_string(io, schemaname_len)
        client_len = read_encoded_length(io)
        client = read_encoded_string(io, client_len)
        cout = "ProxySQL LOG QUERY: thread_id=\"#{thread_id}\" username=\"#{username}\" schemaname=\"#{schemaname}\" client=\"#{client}\""
        hid = read_encoded_length(io)
        server_len = read_encoded_length(io)
        server = read_encoded_string(io, server_len)
        
        io.read(1).unpack('C')
        start_time = io.read(8).unpack('Q*')[0]
        io.read(1).unpack('C')
        end_time = io.read(8).unpack('Q*')[0]
        
        io.read(1).unpack('C')
        query_digest = "0x#{io.read(8).unpack('I*').map{|n| sprintf("%X", n)}.join("")}"
        cout <<  " starttime=\"#{Time.at(start_time)}\" endtime=\"#{Time.at(end_time)}\" duration=#{end_time-start_time}us digest=\"#{query_digest}\""
        
        query_len = read_encoded_length(io)
        query = read_encoded_string(io, query_len)
        cout << "\n#{query}\n"
        puts cout
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

