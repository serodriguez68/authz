# Create logger that ignores messages containing “CACHE”
class CacheFreeLogger < ::Logger
  def debug(message, *args, &block)
    super unless message.include? 'CACHE'
  end
end

# Overwrite ActiveRecord's logger
unless Rails.env.test?
  ActiveRecord::Base.logger = ActiveSupport::TaggedLogging.new(
    CacheFreeLogger.new(STDOUT)
  )
end


