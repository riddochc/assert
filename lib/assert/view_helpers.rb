require 'assert/config_helpers'

module Assert

  module ViewHelpers

    def self.included(receiver)
      receiver.class_eval do
        include Assert::ConfigHelpers
        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods

      def option(name, *default_vals)
        default = default_vals.size > 1 ? default_vals : default_vals.first
        define_method(name) do |*args|
          if !(value = args.size > 1 ? args : args.first).nil?
            instance_variable_set("@#{name}", value)
          end
          (val = instance_variable_get("@#{name}")).nil? ? default : val
        end
      end

    end

    module InstanceMethods

      # get the formatted run time for an idividual test
      def test_run_time(test, format = '%.6f')
        format % test.run_time
      end

      # get the formatted result rate for an individual test
      def test_result_rate(test, format = '%.6f')
        format % test.result_rate
      end

      # show any captured output
      def captured_output(output)
        "--- stdout ---\n"\
        "#{output}"\
        "--------------"
      end

      def test_count_statement
        "#{self.count(:tests)} test#{'s' if self.count(:tests) != 1}"
      end

      def result_count_statement
        "#{self.count(:results)} result#{'s' if self.count(:results) != 1}"
      end

      # generate a comma-seperated sentence fragment given a list of items
      def to_sentence(items)
        if items.size <= 2
          items.join(items.size == 2 ? ' and ' : '')
        else
          [items[0..-2].join(", "), items.last].join(", and ")
        end
      end

      # generate an appropriate result summary msg for all tests passing
      def all_pass_result_summary_msg
        if self.count(:results) < 1
          "uhh..."
        elsif self.count(:results) == 1
          "pass"
        else
          "all pass"
        end
      end

      # print a result summary message for a given result type
      def result_summary_msg(result_type)
        if result_type == :pass && self.all_pass?
          self.all_pass_result_summary_msg
        else
          "#{self.count(result_type)} #{result_type.to_s}"
        end
      end

      # generate a sentence fragment describing the breakdown of test results
      # if a block is given, yield each msg in the breakdown for custom formatting
      def results_summary_sentence
        summaries = self.ocurring_result_types.map do |result_sym|
          summary_msg = self.result_summary_msg(result_sym)
          block_given? ? yield(summary_msg, result_sym) : summary_msg
        end
        self.to_sentence(summaries)
      end

    end

    module Ansi

      # Table of supported styles/codes (http://en.wikipedia.org/wiki/ANSI_escape_code)

      CODES = {
        :clear            => 0,
        :reset            => 0,
        :bright           => 1,
        :bold             => 1,
        :faint            => 2,
        :dark             => 2,
        :italic           => 3,
        :underline        => 4,
        :underscore       => 4,
        :blink            => 5,
        :slow_blink       => 5,
        :rapid            => 6,
        :rapid_blink      => 6,
        :invert           => 7,
        :inverse          => 7,
        :reverse          => 7,
        :negative         => 7,
        :swap             => 7,
        :conceal          => 8,
        :concealed        => 8,
        :hide             => 9,
        :strike           => 9,

        :default_font     => 10,
        :font_default     => 10,
        :font0            => 10,
        :font1            => 11,
        :font2            => 12,
        :font3            => 13,
        :font4            => 14,
        :font5            => 15,
        :font6            => 16,
        :font7            => 17,
        :font8            => 18,
        :font9            => 19,
        :fraktur          => 20,
        :bright_off       => 21,
        :bold_off         => 21,
        :double_underline => 21,
        :clean            => 22,
        :italic_off       => 23,
        :fraktur_off      => 23,
        :underline_off    => 24,
        :blink_off        => 25,
        :inverse_off      => 26,
        :positive         => 26,
        :conceal_off      => 27,
        :show             => 27,
        :reveal           => 27,
        :crossed_off      => 29,
        :crossed_out_off  => 29,

        :black            => 30,
        :red              => 31,
        :green            => 32,
        :yellow           => 33,
        :blue             => 34,
        :magenta          => 35,
        :cyan             => 36,
        :white            => 37,

        :on_black         => 40,
        :on_red           => 41,
        :on_green         => 42,
        :on_yellow        => 43,
        :on_blue          => 44,
        :on_magenta       => 45,
        :on_cyan          => 46,
        :on_white         => 47,

        :frame            => 51,
        :encircle         => 52,
        :overline         => 53,
        :frame_off        => 54,
        :encircle_off     => 54,
        :overline_off     => 55,
      }

      def self.code_for(*style_names)
        style_names.map{ |n| "\e[#{CODES[n]}m" if CODES.key?(n) }.compact.join('')
      end

    end

  end

end
