# frozen_string_literal: true

# this class should only exist for compatibility for one release to complete enqueued jobs after upgrade
# it basically expects DeleteObjectHierarchyWorker#compatibility to do the job
DeletePlainObjectWorker = DeleteObjectHierarchyWorker
