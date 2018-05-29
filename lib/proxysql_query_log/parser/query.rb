module ProxysqlQueryLog
  class Query
    class << self
      def create(thread_id, username, schema_name, client, hid, server, start_time, end_time, digest, query)
        q = Query.new
        q.thread_id = thread_id
        q.username = username
        q.schema_name = schema_name
        q.client = client
        q.hid = hid
        q.server = server
        q.start_time = start_time
        q.end_time = end_time
        q.digest = digest
        q.query = query

        q
      end
    end

    attr_accessor :thread_id, :username, :schema_name, :client, :hid, :server, :start_time, :end_time, :digest, :query

    def print
      puts "ProxySQL LOG QUERY: thread_id=\"#{@thread_id}\" username=\"#{@username}\" schema_name=\"#{@schema_name}\" client=\"#{@client}\" HID=#{@hid} server=\"#{@server}\" starttime=\"#{Time.at(@start_time/1000/1000)}\" endtime=\"#{Time.at(@end_time/1000/1000)}\" duration=#{@end_time - @start_time}us digest=\"#{@digest}\"
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
