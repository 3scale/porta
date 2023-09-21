# frozen_string_literal: true

module Kubernetes
  module Tools

    module_function

    def running_on_kubernetes?
      Dir.exist?('/run/secrets/kubernetes.io') || ENV.key?('KUBERNETES_PORT')
    end

    def available_cpus
      shares = 1024 # the default CPU shares value
      if File.exist?('/sys/fs/cgroup/cgroup.controllers')
        # Cgroups v2
        # Using the formula from https://github.com/kubernetes/kubernetes/blob/release-1.27/pkg/kubelet/cm/cgroup_manager_linux.go#L570-L574
        weight = Integer(File.read('/sys/fs/cgroup/cpu.weight'))
        shares = (((weight - 1) * 262142) / 9999) + 2
      else
        # Cgroups v1
        rd = File.read('/sys/fs/cgroup/cpu/cpu.shares')
        shares = Integer(File.read('/sys/fs/cgroup/cpu/cpu.shares'))
      end
      (shares / 1024.0).ceil
    rescue StandardError => exception
      warn "WARNING: Caught exception: #{exception}"
    end

    def kubernetes_cpu_request
      available_cpus if running_on_kubernetes?
    rescue StandardError => exception
      warn "WARNING: Caught exception: #{exception}"
    end
  end
end
