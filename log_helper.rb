module LogHelper
  module_function

  def debug(message)
    puts "DEBUG: #{message}" if ENV['DEBUG']
    $stdout.flush
  end

  def info(message)
    puts "INFO: #{message}"
    $stdout.flush
  end

  def warn(message)
    puts "WARN: #{message}"
    $stdout.flush
  end

  def error(message)
    puts "ERROR: #{message}"
    $stdout.flush
  end
end