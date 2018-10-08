# frozen_string_literal: true


Webpacker::Compiler.prepend(Module.new do
  def compile
    if stale?
      record_compilation_digest
      run_webpack.tap do |success|
        remove_compilation_digest if !success
      end
    else
      true
    end
  end

  private

  def remove_compilation_digest
    compilation_digest_path.delete if compilation_digest_path.exist?
  rescue Errno::ENOENT, Errno::ENOTDIR
  end

end)
