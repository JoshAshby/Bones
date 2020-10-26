# frozen_string_literal: true

# Temp work around for tty-logger's remove_handler not working as expected
# See my bug report here: https://github.com/piotrmurach/tty-logger/issues/14
handlers = LOGGER.instance_variable_get :@ready_handlers
console_handler = handlers.find { _1.is_a? TTY::Logger::Handlers::Console }
LOGGER.remove_handler(console_handler) unless ENV["STDOUT_TEST_LOGS"]
