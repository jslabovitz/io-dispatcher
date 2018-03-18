module IO

  class Dispatcher

    def initialize(timeout: nil)
      @timeout = timeout
      @io_handlers = [{}, {}, {}]
    end

    def add_io_handler(input: nil, output: nil, exception: nil, handler: nil, &block)
      mode, io = if input
        [0, input]
      elsif output
        [1, output]
      elsif exception
        [2, exception]
      end
      @io_handlers[mode][io] = handler || block
    end

    def set_timeout_handler(timeout, &block)
      @timeout_handler = block
    end

    def run
      loop do
        if (ready = IO.select(*@io_handlers.map(&:keys), @timeout))
          ready.each_with_index do |mode, i|
            mode.each { |io| @io_handlers[i][io].call(io) }
          end
        else
          @timeout_handler.call if @timeout_handler
        end
      end
    end

  end

end