# frozen_string_literal: true

module Crystalball
  module RSpec
    class PredictorRunner < Runner
      class << self
        def run(args = [], err = $stderr, out = $stdout)
          Crystalball.log :info, "Crystalball starts to glow..."
          prediction = build_prediction

          if prediction.empty?
            Crystalball.log :warn, "No specs predicted to run."
            return 0
          end

          path = Pathname.new(config['predicted_specs_file_path'])
          path.dirname.mkpath
          path.write(prediction.join("\n"))

          Crystalball.log :info, "Raw predicted spec examples written to #{path}"
          0
        end
      end
    end
  end
end
