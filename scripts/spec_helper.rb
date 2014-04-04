
require 'serverspec'
require 'pathname'
require 'net/ssh'
require 'docker'

Docker.url = "http://localhost:4243"

containerDir = ENV['DIR']
containerID = `cat #{containerDir}/host.id`
testServerHostname, testServerPort = `docker port #{containerID} 13337`.split ':'

tests = Dir.glob(containerDir + '/files/tests/*')

tests.each { |testPath|
  describe testPath do
    it "should return exit code 0" do
      test = Pathname.new(testPath).basename
      print test
      output = `./telnet.sh #{testServerHostname} #{testServerPort} #{test}`
      print output
    end
  end
}
