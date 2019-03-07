module RetryHelper
  def retry_until(condition:, retry_count: 5, wait: 0.25)
    count = 0

    until condition.call
      raise 'timed out' if count > retry_count

      yield

      sleep wait
      count += 1
    end
  end
end
