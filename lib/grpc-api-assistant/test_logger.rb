# frozen_string_literal: true

require 'logger'

module GrpcApiAssistant
  module TestLogger
    def self.debug(message)
      create_logger.each { |l| l.debug(message) }
    end

    def self.warn(message)
      create_logger.each { |l| l.warn(message) }
    end

    def self.fatal(message)
      create_logger.each { |l| l.fatal(message) }
    end

    def self.error(message)
      create_logger.each { |l| l.error(message) }
    end

    def self.info(message)
      create_logger.each { |l| l.info(message) }
    end

    def self.create_logger
      @@loggers ||= []

      if @@loggers.empty?
        log_file_name = 'cucumber_tests.log'
        log_dir_name = 'logs'

        @@loggers = []
        @@loggers << Logger.new($stdout)

        log_to_file = (Helpers.get_env('log_to_file') || 'true').downcase == true.to_s
        if log_to_file
          Dir.mkdir(log_dir_name) unless File.exist?(log_dir_name)
          @@loggers << Logger.new("#{log_dir_name}/#{log_file_name}", 'daily')
        end

        set_log_level

        if @@loggers.length == 1
          info 'Only the STDOUT logger is being used'
        else
          info "Both the STDOUT and File logger are being used.  Log files written to logs/#{log_file_name}"
        end

        info "current logging level is #{@@loggers.first.level}"
      end

      @@loggers
    end

    def self.set_log_level
      log_level = (Helpers.get_env('log_level') || 'info').downcase

      case log_level
      when 'fatal'
        @@loggers.each { |l| l.level = Logger::FATAL }
      when 'error'
        @@loggers.each { |l| l.level = Logger::ERROR }
      when 'warn'
        @@loggers.each { |l| l.level = Logger::WARN }
      when 'info'
        @@loggers.each { |l| l.level = Logger::INFO }
      else
        @@loggers.each { |l| l.level = Logger::DEBUG }
      end
    end
  end
end
