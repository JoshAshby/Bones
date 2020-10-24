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

  module_function

  # TODO: Make this configurable to the Fossil library
  def fossil_binary
    @fossil_binary ||= CONFIG.dig("bones", "fossil_binary")
  end

  # TODO: Make this configurable to the Fossil library
  def log(*msg)
    LOGGER.fossil(*msg)
  end

  # Runs the Fossil binary with the given set of commands, writing STDOUT and
  # STDERR to the log and returning the log and ProcessStatus wrapped in a
  # rdoc-ref:Fossil::CmdResult stuct.
  #
  # Fails with a rdoc-ref:Fossil::FossilCommandError if Fossil exits with a
  # non-zero status.
  def run_fossil_command *args
    result = run_command fossil_binary, *args

    Fossil.log "Ran fossil command `fossil #{ args.join ' ' }'", status: result.exitstatus
    Fossil.log result.log

    return result if result.success?

    exception = Fossil::FossilCommandError.new "Abnormal exit status `#{ result.exitstatus }' from Fossil", result
    fail exception
  end

  def run_command command, *args
    log, status = Open3.capture2e command, *args

    CmdResult.new status, log
  end
end
