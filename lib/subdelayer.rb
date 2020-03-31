require "subdelayer/version"
require "active_support/core_ext/array"

module Subdelayer

  class NotASubtitleFileError < StandardError
    def message
      "This file does not seem to be a .srt subtitle file"
    end
  end

  class DelayError < StandardError
    def message
      "The delay is too big, causing some values to be negative or over 24 hours, which is not supported"
    end
  end

  class Delayer

    def initialize(delay:, filename:)
      @delay = delay
      @filename = filename
    end

    def perform
      r = chunks.map do |(index, time, *text)|
        raise NotASubtitleFileError unless time&.include?('-->')

        [index, delay_time(time), *text].join("\n")
      end.join("\n\n")
    end

    private

    def delay_time(time)
      start, finish = time.split('-->').map(&:strip)

      [delay_value(start), delay_value(finish)].join(' --> ')
    end

    def delay_value(value)
      parsed_time = Time.parse(value)
      new_time = parsed_time + @delay
      raise DelayError if parsed_time.to_date != new_time.to_date

      new_time.strftime('%H:%M:%S,%3N')
    end

    def chunks
      lines.split("").reject(&:blank?)
    end

    def lines
      File.readlines(@filename).map(&:strip)
    end
  end
end
