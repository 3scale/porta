module ThreeScale
  class AfterCommitOnDestroy

    THREAD_LOCAL_QUEUE = :__after_commit_on_destroy

    class << self
      def enqueue(procedure)
        queue << procedure
      end

      def run!
        while x = queue.shift
          x.call
        end
      end

      def clear!
        Thread.current[THREAD_LOCAL_QUEUE] = []
      end

      def queue
        Thread.current[THREAD_LOCAL_QUEUE] ||= []
      end
    end
  end
end
