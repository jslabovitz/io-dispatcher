class IO

  class Dispatcher

    def initialize
      @io_handlers = [{}, {}, {}]
      @timeout = nil
      @jobs = []  # array of [Float run_at, Proc], kept sorted
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

    def schedule(after: nil, &block)
      run_at = clock_time + (after || 0)
      @jobs << [run_at, block]
      @jobs.sort_by!(&:first)
    end

    def run(&block)
      @stop = false
      until @stop
        yield if block_given?
        run_jobs!
        arrays = @io_handlers.map(&:keys)
        break if !@timeout && arrays.flatten.empty?
        timeout = effective_timeout
        if (ready = IO.select(*arrays, timeout))
          ready.each_with_index do |mode, i|
            mode.each do |io|
              (handler = @io_handlers[i][io]) && handler.call(io)
            end
          end
        elsif @timeout && timeout >= @timeout
          @timeout_handler&.call
        end
      end
    end

    def stop
      @stop = true
    end

    private

    def run_jobs!
      now = clock_time
      while @jobs.first && @jobs.first[0] <= now
        _, job = @jobs.shift
        job.call
      end
    end

    def effective_timeout
      return @timeout if @jobs.empty?
      now = clock_time
      secs = [@jobs.first[0] - now, 0].max
      # Use whichever wakes us up sooner: the next job, or the user's timeout.
      @timeout ? [secs, @timeout].min : secs
    end

    def clock_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

  end

end