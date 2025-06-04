# frozen_string_literal: true

require_relative 'runner'
require 'parallel'

module Crystalball
  module RSpec
    class ParallelRunner < Runner
      class << self
        def run(args = [], err = $stderr, out = $stdout)
          Crystalball.log :info, "Crystalball starts to glow..."
          prediction = build_prediction

          spec_files = prediction.map { |line| line.sub(/\[.*\]$/, '') }.sort.uniq

          if spec_files.empty?
            Crystalball.log :warn, "No specs predicted to run."
            return 0
          end

          num_processes = ENV["PARALLEL_TEST_PROCESSORS"].to_i > 0 ? ENV["PARALLEL_TEST_PROCESSORS"].to_i : Parallel.processor_count

          Crystalball.log :info, "Running specs in parallel using #{num_processes} workers"

          groups = spec_files.each_slice((spec_files.size.to_f / num_processes).ceil).to_a

          results = Parallel.map(groups, in_processes: num_processes) do |group|
            ::RSpec::Core::Runner.run(group, err, out)
          end

          results.all?(0) ? 0 : 1
        end
      end
    end
  end
end
