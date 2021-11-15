require 'yard'
require 'rake/clean'

task default: [:package_gem, :yard_task]
task package_gem: [:test]
task test: [:generate_grpc]

task :package_gem do
  command = "gem build grpc-api-assistant.gemspec"
  sh command
  if $?.exitstatus != 0
    fail "Command #{command} failed"
  end
end

task :generate_grpc do
  proto_dir = "protos"
  dest_root = "generated/proto"
  FileUtils.mkdir_p(dest_root) unless File.exists?(dest_root)

  command = "grpc_tools_ruby_protoc -I #{proto_dir} " \
            " --ruby_out=#{dest_root} --grpc_out=#{dest_root}" \
            " #{Dir.glob(proto_dir + '/**/*.proto').join(' ')}"
  sh command
  if $?.exitstatus != 0
    fail "gRPC command failed: #{command}"
  end
end

task :test do
  command = "cucumber"
  sh command
  if $?.exitstatus != 0
    fail "Command #{command} failed!"
  end
end

task :yard_task do
  command = "yardoc --plugin yard-cucumber 'lib/**/*.rb' "
  sh command
end

CLEAN.include 'logs'
CLEAN.include '*.gem'
CLEAN.include '*Gemfile.lock'
CLEAN.include 'generated'
