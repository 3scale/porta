require 'diff/lcs'
require 'diff/lcs/hunk'

module ThreeScale
  class Diff
    attr_reader :base, :changed

    def initialize(base, changed)
      @base = base || ""
      @changed = changed || ""
    end

    def pieces
      @pieces ||= ::Diff::LCS.diff(chunked(base), chunked(changed))
    end

    def chunked(what)
      what.split(/\n/).map { |e| e.chomp }
    end

    def stats
      return @stats if @stats

      @stats = Hash.new(0)
      pieces.flatten.each do |change|
        case
        when change.adding?
          @stats[:addition] += 1
        when change.deleting?
          @stats[:deletion] += 1
        when change.changing?
          @stats[:change] += 1
        end
      end

      @stats
    end

    def context_lines
      3
    end

    def format
      :unified
    end

    def to_s
      # This is snagged from diff/lcs/ldiff.rb (which is a commandline tool)
      output = ""
      return output if pieces.empty?
      oldhunk = hunk = nil
      file_length_difference = 0
      pieces.each do |piece|
        begin
          hunk = ::Diff::LCS::Hunk.new(
            chunked(base), chunked(changed), piece, context_lines, file_length_difference
          )
          file_length_difference = hunk.file_length_difference
          next unless oldhunk
          # Hunks may overlap, which is why we need to be careful when our
          # diff includes lines of context. Otherwise, we might print
          # redundant lines.
          if (context_lines > 0) && hunk.overlaps?(oldhunk)
            hunk.unshift(oldhunk)
          else
            output << oldhunk.diff(format)
          end
        ensure
          oldhunk = hunk
          output << "\n"
        end
      end
      #Handle the last remaining hunk
      output << oldhunk.diff(format) << "\n"
    end

  end
end
