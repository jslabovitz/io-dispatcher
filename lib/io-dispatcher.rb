class IO

  class Dispatcher

    def initialize
      @io_handlers = [{}, {}, {}]
      @timeout = nil
    end

    def add_io_handler(input: nil, output: nil, exception: nil, handler: nil, &block)
      handler ||= block
      set_io_handler(0, input, handler)     if input
      set_io_handler(1, output, handler)    if output
      set_io_handler(2, exception, handler) if exception
    end

    def remove_io_handler(input: nil, output: nil, exception: nil)
      set_io_handler(0, input, nil)     if input
      set_io_handler(1, output, nil)    if output
      set_io_handler(2, exception, nil) if exception
    end

    def set_io_handler(mode, io, handler)
      if handler
        @io_handlers[mode][io] = handler
      else
        @io_handlers[mode].delete(io)
      end
    end

    def set_timeout_handler(timeout, &block)
      @timeout = timeout
      @timeout_handler = block
    end

    def run(&block)
      loop do
        yield if block_given?
        arrays = @io_handlers.map(&:keys)
        break if !@timeout && arrays.flatten.empty?
        if (ready = IO.select(*arrays, @timeout))
          ready.each_with_index do |mode, i|
            mode.each do |io|
              (handler = @io_handlers[i][io]) && handler.call(io)
            end
          end
        else
          @timeout_handler.call if @timeout_handler
        end
      end
    end

  end

end