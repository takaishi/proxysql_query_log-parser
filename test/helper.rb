def to_binary(q)
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

  buf
end

def total_length(q)
  len = 0

  # thread_id
  len += 2

  # username
  len += (1 + q.username.size)

  # schema_name
  len += (1 + q.schema_name.size)

  # client
  len += (1 + q.client.size)

  # hid
  len += 1

  # server
  len += (1 + q.server.size)

  # start_time
  len += (1 + 8)

  # end_time
  len += (1 + 8)

  # digest
  len += (1 + q.digest.size)

  # query
  len += (1 + q.query.size)

  len
end