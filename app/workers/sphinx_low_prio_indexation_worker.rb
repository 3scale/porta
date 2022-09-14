# frozen_string_literal: true

# This worker is used for periodic full reindexation of all of the models at once
# Unlike real-time indexation triggered on model updates, and handled via the default queue,
# this one is handled by a lower priority queue, which also allows managing the jobs better,
# e.g. delete all at once
class SphinxLowPrioIndexationWorker < SphinxIndexationWorker
  queue_as :optional
end
