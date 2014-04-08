
require 'serverspec'
require 'pathname'
require 'net/ssh'
require 'docker'
require 'json'

Docker.url = "http://localhost:4243"

containerDir = ENV['DIR']
containerID = `cat #{containerDir}/host.id`
testServerHostname, testServerPort = `docker port #{containerID} 13337`.strip!.split ':'

tests = Dir.glob(containerDir + '/files/tests/*')

tests.each { |testPath|
  describe testPath do
    it "should return exit code 0" do
      test = Pathname.new(testPath).basename.to_s
      output = `./telnet.sh #{testServerHostname} #{testServerPort} #{test}`.to_s.strip!
      res = JSON.parse output
      res['code'].should equal(0)
    end
  end
}
