# frozen_string_literal: true

# copy pasta, with modifications, from the CommonLogger plugin that ships with
# Roda
module RequestLogger
  module InstanceMethods
    private

    # rubocop:disable Layout/LineLength
    # Log request/response information in common log format to logger.
    def _roda_after_90__common_logger(result)
      return unless result && result[0] && result[1]

      env = @_request.env

      qs = env["QUERY_STRING"]
      query_string = "?#{ qs }" unless qs.empty?

      length = result[1]["Content-Length"]
      length = "" if length == "0"

      LOGGER.request "#{ env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR'] || '-' } - \"#{ env['REQUEST_METHOD'] } #{ env['SCRIPT_NAME'] }#{ env['PATH_INFO'] }#{ query_string } #{ env['HTTP_VERSION'] }\" #{ result[0] } #{ length }\n"
    end
    # rubocop:enable Layout/LineLength
  end
end
