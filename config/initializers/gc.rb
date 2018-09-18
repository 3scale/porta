if defined?(GC)
  GC.enable_stats if GC.respond_to?(:enable_stats)

  if defined?(GC::Profiler)
    GC::Profiler.enable if GC::Profiler.respond_to?(:enable)
  end
end
