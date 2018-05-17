module ProxysqlQueryLog
  class Query
    attr_accessor :thread_id, :username, :schema_name, :client, :hid, :server, :start_time, :end_time, :digest, :query
    #def initialize(thread_id, username, schemaname, client, hid, server, start_time, end_time, digest, query)
    #  @thread_id = thread_id
    #  @username = username
    #  @schemaname = schemaname
    #  @client = client
    #  @hid = hid
    #  @server = server
    #  @start_time = start_time
    #  @end_time = end_time
    #  @digest = digest
    #  @query = query 
    #end

    def print
      puts "ProxySQL LOG QUERY: thread_id=\"#{@thread_id}\" username=\"#{@username}\" schema_name=\"#{@schema_name}\" client=\"#{@client}\" HID=#{@hid} server=\"#{@server}\" starttime=\"#{Time.at(@start_time)}\" endtime=\"#{Time.at(@end_time)}\" duration=#{@end_time - @start_time}us digest=\"#{@digest}\"
#{@query}"
    end

    def to_json
      {
          thread_id: thread_id,
          username: username,
          schema_name: schema_name,
          client: client,
          HID: hid,
          server: server,
          start_time: Time.at(start_time/1000/1000),
          end_time: Time.at(end_time/1000/1000),
          duration: end_time - start_time,
          digest: digest
      }.to_json
    end
  end
end
