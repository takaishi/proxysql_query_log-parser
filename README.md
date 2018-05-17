# ProxySQL Query Log Parser


## Usage

```
require 'proxysql_query_log/parser'

parser = ProxysqlQueryLog::Parser.new
parser.load_file('queries.log.00000011').each do |query|
  query.print
end
```
