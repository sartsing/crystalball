# frozen_string_literal: true

require 'crystalball/rspec/standard_prediction_builder'

module Crystalball
  module RSpec
    class Runner
      # Class for storing local runner configuration
      class Configuration
        def initialize(config = {}) # rubocop:disable Metrics/MethodLength
          @values = {
            'execution_map_path' => 'tmp/crystalball_data.yml',
            'map_expiration_period' => 86_400,
            'repo_path' => Dir.pwd,
            'predicted_specs_file_path' => 'tmp/predicted_specs.txt',
            'requires' => ['crystalball/rspec/predictor_runner'],
            'diff_from' => 'HEAD',
            'diff_to' => nil,
            'runner_class_name' => 'Crystalball::RSpec::Runner',
            'prediction_builder_class_name' => 'Crystalball::RSpec::StandardPredictionBuilder',
            'log_level' => :info,
            'log_file' => 'log/crystalball.log',
            'predictor_runner' => false
          }.merge(config)
        end

        def to_h
          dynamic_values = {}
          (private_methods - Object.private_instance_methods - %i[run_requires values raw_value]).each do |method|
            dynamic_values[method.to_s] = send(method)
          end

          values.merge(dynamic_values)
        end

        def [](key)
          respond_to?(key, true) ? send(key) : raw_value(key)
        end

        def []=(key, value)
          values[key] = value
        end

        private

        def raw_value(key)
          ENV.fetch("CRYSTALBALL_#{key.to_s.upcase}", values[key])
        end

        def prediction_builder_class
          @prediction_builder_class ||= begin
            run_requires

            Object.const_get(self['prediction_builder_class_name'])
          end
        end

        def runner_class
          @runner_class ||= begin
            run_requires
            self['runner_class_name'] = 'Crystalball::RSpec::PredictorRunner' if self['predictor_runner']
            Object.const_get(self['runner_class_name'])
          end
        end

        def execution_map_path
          @execution_map_path ||= Pathname.new(raw_value('execution_map_path'))
        end

        def repo_path
          @repo_path ||= Pathname.new(raw_value('repo_path'))
        end

        def log_file
          @log_file ||= Pathname.new(raw_value('log_file'))
        end

        attr_reader :values

        def run_requires
          Array(self['requires']).each { |f| require f }
        end
      end
    end
  end
end
