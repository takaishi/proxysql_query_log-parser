# ProxySQL Query Log Parser

[![Build Status](https://travis-ci.org/takaishi/proxysql_query_log-parser.svg?branch=master)](https://travis-ci.org/takaishi/proxysql_query_log-parser)


## Usage

```
require 'proxysql_query_log/parser'

parser = ProxysqlQueryLog::Parser.new
parser.load_file('queries.log.00000011').each do |query|
  query.print
end
```
