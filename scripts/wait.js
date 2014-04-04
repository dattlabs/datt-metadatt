
var http = require('http');
http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('HELO\n');

  console.log("Recv'd message from container. Exiting.");
  process.exit(code=0);
}).listen(41234, '127.0.0.1');

