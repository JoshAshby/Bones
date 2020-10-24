# frozen_string_literal: true

module Fossil
  class Error < StandardError; end
  class ExistingRepositoryError < Error; end

  # Custom error class which is raised when a Fossil command exits with a
  # non-zero status. Contains the ProcessStatus and a string containing the
  # stdout and stderr log of the process call as #fossil_result, wrapped in a
  # rdoc-ref:Fossil::CmdResult
  class FossilCommandError < Error
    attr_reader :cmd_result

    def initialize msg, cmd_result
      super msg

      @cmd_result = cmd_result
    end
  end

  # Container for the status and log of a Fossil command
  class CmdResult
    extend Forwardable

    attr_reader :status, :log

    def_delegators :@status, :success?, :exitstatus

    def initialize status, log
      @status = status
      @log = log
    end
  end

  class Config
    attr_accessor :fossil_binary, :logger
  end

  class << self
    attr_accessor :config

    def configure
      self.config ||= Config.new
      yield config
    end

    # Pass through for config.fossil_binary
    def fossil_binary
      config.fossil_binary
    end

    # Pass through for config.logger.call
    def log *msg
      config.logger.call(*msg)
    end

    # Runs the Fossil binary with the given set of commands, writing STDOUT and
    # STDERR to the log and returning the log and ProcessStatus wrapped in a
    # rdoc-ref:Fossil::CmdResult stuct.
    #
    # Fails with a rdoc-ref:Fossil::FossilCommandError if Fossil exits with a
    # non-zero status.
    def run_fossil_command *args
      result = run_command fossil_binary, *args

      return result if result.success?

      exception = FossilCommandError.new "Abnormal exit status `#{ result.exitstatus }' from Fossil", result
      fail exception
    end

    protected

    def run_command command, *args
      logout, status = Open3.capture2e command, *args

      log "Ran command `fossil #{ args.join ' ' }'", status: status.exitstatus
      log logout

      CmdResult.new status, logout
    end
  end
end
