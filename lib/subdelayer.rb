require "subdelayer/version"
require "active_support/core_ext/array"

module Subdelayer

  class NotASubtitleFileError < StandardError; end

  class Delayer

    def initialize(delay:, filename:)
      @delay = delay
      @filename = filename
    end

    def perform
      r = chunks.map do |(index, time, *text)|
        raise NotASubtitleFileError unless time.include?('-->')

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
      parsed_time += @delay
      parsed_time.strftime('%H:%M:%S,%3N')
    end

    def chunks
      lines.split("").reject(&:blank?)
    end

    def lines
      File.readlines(@filename).map(&:strip)
    end
  end
end
