# frozen_string_literal: true

module Cgroups
  module Tools

    module_function

    # CPU shares in Cgroups v1 or converted from weight in Cgroups v2 in millicores
    def cpu_shares
      # This check is from https://github.com/kubernetes/kubernetes/blob/release-1.27/test/e2e/node/pod_resize.go#L305-L314
      # alternatively, this method can be used: https://kubernetes.io/docs/concepts/architecture/cgroups/#check-cgroup-version
      # (`stat -fc %T /sys/fs/cgroup/` returns `cgroup2fs` or `tmpfs`)
      if File.exist?('/sys/fs/cgroup/cgroup.controllers')
        # Cgroups v2
        # Using the formula from https://github.com/kubernetes/kubernetes/blob/release-1.27/pkg/kubelet/cm/cgroup_manager_linux.go#L570-L574
        weight = Integer(File.read('/sys/fs/cgroup/cpu.weight'))
        shares = (((weight - 1) * 262142) / 9999) + 2
      else
        # Cgroups v1
        shares = Integer(File.read('/sys/fs/cgroup/cpu/cpu.shares'))
      end
      shares
    rescue StandardError => exception
      warn "WARNING: Caught exception getting CPU shares: #{exception}"
    end

    # CPU share in CPU cores, rounded up
    def available_cpus
      shares = cpu_shares
      (shares / 1024.0).ceil if shares
    rescue StandardError => exception
      warn "WARNING: Caught exception calculating available CPUs: #{exception}"
    end

  end
end
