#
# Copyright (c) 2006-2011 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of Ronin.
#
# Ronin is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ronin is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ronin.  If not, see <http://www.gnu.org/licenses/>.
#

require 'ronin/config'
require 'ronin/repository'

module Ronin
  module UI
    #
    # An interactive Ruby {Console} using
    # [Ripl](https://github.com/cldwalker/ripl).
    #
    class Console

      # The history file for the Console session
      HISTORY_FILE = File.join(Config::PATH,'console.log')

      @@color = !(STDOUT.tty?)
      @@short_errors = !(ENV.has_key?('VERBOSE'))
      @@auto_load = []
      @@setup_blocks = []
      @@completions = []

      #
      # Determines whether colorized output will be enabled.
      #
      # @return [Boolean]
      #   Specifies whether colorized output will be enabled.
      #
      # @since 1.0.0
      #
      # @api semipublic
      #
      def Console.color?
        @@color
      end

      #
      # Enables or disables colorized output.
      #
      # @param [Boolean] mode
      #   The new colorized output mode.
      #
      # @return [Boolean]
      #   The colorized output mode.
      #
      # @since 1.0.0
      #
      # @api semipublic
      #
      def Console.color=(mode)
        @@color = mode
      end

      #
      # Determines whether one-line errors will be printed, instead of full
      # backtraces.
      #
      # @return [Boolean]
      #   The Console short-errors setting.
      #
      # @since 1.0.0
      #
      # @api semipublic
      #
      def Console.short_errors?
        @@short_errors
      end

      #
      # Enables or disables the printing of one-lin errors.
      #
      # @param [Boolean] mode
      #   The new Console short-errors setting.
      #
      # @return [Boolean]
      #   The Console short-errors setting.
      #
      # @since 1.0.0
      #
      # @api semipublic
      #
      def Console.short_errors=(mode)
        @@short_errors = mode
      end

      #
      # Adds a tab-completion rule to the Console.
      #
      # @param [Hash] options
      #   Pattern matching options.
      #
      # @yield [(match)]
      #   The given block will be passed the matched pattern,
      #   and will return an Array of possible completions.
      #
      # @yieldparam [String] match
      #   The pattern match.
      #
      # @return [true]
      #   Specifies whether the complete rule was successfully added.
      #
      # @since 1.2.0
      #
      # @api semipublic
      #
      def Console.complete(options,&block)
        @@completions << [options, block]
      end

      #
      # The list of files to load before starting the Console.
      #
      # @return [Array]
      #   The files to require when the Console starts.
      #
      # @api semipublic
      #
      def Console.auto_load
        @@auto_load
      end

      #
      # Adds a block to be ran from within the Console after it is
      # started.
      #
      # @yield []
      #   The block to be ran from within the Console.
      #
      # @api semipublic
      #
      def Console.setup(&block)
        @@setup_blocks << block if block
      end

      #
      # Starts a Console.
      #
      # @param [Hash{Symbol => Object}] variables
      #   Instance variable names and values to set within the console.
      #
      # @yield []
      #   The block to be ran within the Console, after it has been setup.
      #
      # @return [Console]
      #   The instance context the Console ran within.
      #
      # @example
      #   Console.start
      #   # >>
      #
      # @example
      #   Console.start(:var => 'hello')
      #   # >> @var
      #   # # => "hello"
      #
      # @example
      #   Console.start { @var = 'hello' }
      #   # >> @var
      #   # # => "hello"
      #
      # @api semipublic
      #
      def Console.start(variables={},&block)
        require 'ripl'
        require 'ripl/completion'
        require 'ripl/multi_line'
        require 'ripl/auto_indent'
        require 'ripl/color_result' if @@color
        require 'ripl/short_errors' if @@short_errors

        require 'ronin'
        require 'ronin/repositories'
        require 'pp'

        # append the current directory to $LOAD_PATH for Ruby 1.9.
        $LOAD_PATH << '.' unless $LOAD_PATH.include?('.')

        # require any of the auto-load paths
        @@auto_load.each { |path| require path }

        context = class << self.new; self; end

        # populate instance variables
        variables.each do |name,value|
          context.instance_variable_set("@#{name}".to_sym,value)
        end

        # run any setup-blocks
        @@setup_blocks.each do |setup_block|
          context.instance_eval(&setup_block)
        end

        # run the supplied configuration block is given
        context.instance_eval(&block) if block

        @@completions.each do |options,block|
          Bond.complete(options,&block)
        end

        # Start the Ripl console
        Ripl.start(
          :argv => [],
          :name => 'ronin',
          :binding => context.instance_eval { binding },
          :history => HISTORY_FILE,
          :irbrc => false
        )

        return context
      end

      class << self
        #
        # Inspects the console.
        #
        # @return [String]
        #   The inspected console.
        #
        # @since 1.0.0
        #
        # @api semipublic
        #
        def inspect
          "#<Ronin::UI::Console>"
        end
      end

    end
  end
end
