module ThreeScale
  module Socket
    module ClassMethods
      def accepts_connections?(host, port)
        ::Socket.tcp(host, port, connect_timeout: 1) { true }
      rescue
        false
      end
    end

    extend ClassMethods
  end
end
