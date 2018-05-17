# ProxySQL Query Log Parser


## Usage

```
require 'proxysql_query_log_parser'

parser = ProxysqlQueryLogParser::Parser.new
parser.load_file('queries.log.00000011').each do |query|
  query.print
end
```
