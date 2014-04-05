
var net = require('net');
var execFile = require('child_process').execFile;
var fs = require('fs');

var testDir = __dirname + '/tests';
var scripts = fs.readdirSync(testDir);

var server = net.createServer(function (socket) {
  socket.write('Test server\r\n');
  socket.on('data', function (data) {
    var test = data.toString().trim();
    if (scripts.indexOf(test) == -1) {
      console.log("Attempt to run invalid test: " + test);
      socket.write("Nice try! Invalid test.\n");
      return;
    }
    console.log('Running test: ' + test);
    var stdout, stderr, error = "";
    var child = execFile('./' + test, {cwd: testDir }, function (err, so, se) {
      stdout = so.trim();
      stderr = se.trim();
      console.log('[STDOUT]:    ' + stdout);
      console.log('[STDERR]:    ' + stderr);
      if (err != null) {
        error = err.toString().trim();
        console.log('[ERROR]:     ' + error);
      }
    });
    child.on('exit', function (code) {
      console.log('[EXIT CODE]: ' + code);
      socket.write(JSON.stringify({stdout: stdout, stderr: stderr, error: error, code: code}) + '\n');
    });
  });
});

server.listen(13337, '0.0.0.0');
