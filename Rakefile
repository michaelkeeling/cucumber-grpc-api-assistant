# frozen_string_literal: true

require 'rake/clean'

task default: [:package_gem]
task package_gem: [:test]
task test: [:generate_grpc]

task :package_gem do
  command = 'gem build grpc-api-assistant.gemspec'
  sh command
  raise "Command #{command} failed" if $?.exitstatus != 0
end

task :generate_grpc do
  proto_dir = './protos'
  dest_root = 'generated/proto'
  FileUtils.mkdir_p(dest_root) unless File.exist?(dest_root)

  command = "grpc_tools_ruby_protoc -I #{proto_dir} " \
            " --ruby_out=#{dest_root} --grpc_out=#{dest_root}" \
            " #{Dir.glob("#{proto_dir}/**/*.proto").join(' ')}"
  sh command
  raise "gRPC command failed: #{command}" if $?.exitstatus != 0
end

task :test do
  command = 'cucumber'
  sh command
  raise "Command #{command} failed!" if $?.exitstatus != 0
end

CLEAN.include 'logs'
CLEAN.include '*.gem'
CLEAN.include '*Gemfile.lock'
CLEAN.include 'generated'
