class IO

  class Dispatcher

    def initialize
      @io_handlers = [{}, {}, {}]
      @timeout = nil
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

    def remove_io_handler(input: nil, output: nil, exception: nil)
      mode, io = if input
        [0, input]
      elsif output
        [1, output]
      elsif exception
        [2, exception]
      end
      @io_handlers[mode].delete(io)
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