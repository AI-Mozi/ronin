#
# Copyright (c) 2006-2022 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of ronin.
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
# along with Ronin.  If not, see <https://www.gnu.org/licenses/>.
#

require 'ronin/cli/command'
require 'ronin/support/network/ip_range'

require 'command_kit/options/input'

module Ronin
  class CLI
    module Commands
      #
      # Enumerates over the IP ranges.
      #
      # ## Usage
      #
      #     ronin iprange [options] {IP_RANGE ... | --start IP --stop IP | --input FILE}
      #
      # ## Options
      #
      #    -i, --input FILE                 Optional input file
      #        --start IP                   Starting IP address
      #        --stop IP                    Stopping IP address
      #    -h, --help                       Print help information
      #
      # ## Arguments
      #
      #    [IP_RANGE ...]                   The IP Range to enumerate
      #
      # ## Examples
      #
      #    ronin iprange 1.1.1.0/24
      #    ronin iprange 1.1.1.*
      #    ronin iprange 1.1.2-4.10-50
      #    ronin iprange --start 1.1.1.10 --stop 1.1.4.100
      #    ronin iprange --input list.txt
      # 
      class Iprange < Command

        include CommandKit::Options::Input

        usage '[options] {IP_RANGE ... | --start IP --stop IP | --input FILE}'

        option :start, value: {
                         type: String,
                         usage: 'IP'
                       },
                       desc: 'Starting IP address' do |ip|
                         @start << ip
                       end

        option :stop, value: {
                        type: String,
                        usage: 'IP'
                      },
                      desc: 'Stopping IP address' do |ip|
                        @stop << ip
                      end

        argument :ip_range, required: false,
                            repeats:  true,
                            desc:     'The IP Range to enumerate'

        description 'Enumerates over IP ranges'

        examples [
          "1.1.1.0/24",
          "1.1.1.*",
          "1.1.2-4.10-50",
          "--start 1.1.1.10 --stop 1.1.4.100",
          "--input list.txt"
        ]

        #
        # Initializes the `ronin iprange` command.
        #
        def initialize(**kwargs)
          super(**kwargs)

          @start = []
          @stop  = []
        end

        #
        # Runs the `ronin iprange` command.
        #
        # @param [Array<String>] ip_ranges
        #   Optional list of IP ranges to enumerate.
        #
        def run(*ip_ranges)
          if !ip_ranges.empty?
            ip_ranges.each do |ip_range|
              print_ip_range ip_range
            end
          elsif !@start.empty? && !@stop.empty?
            unless @start.length == @stop.length
              print_error "must specify an equal number of --start and --stop options"
              exit -1
            end

            @start.zip(@stop).each do |(start,stop)|
              range = Support::Network::IPRange::Range.new(start,stop)

              range.each do |ip|
                puts ip
              end
            end
          elsif !input_files.empty?
            open_input_stream(*input_files) do |io|
              io.each_line(chomp: true) do |line|
                print_ip_range line
              end
            end
          else
            print_error "must specify either IP range arguments or --start and --stop options"
            exit -1
          end
        end

        #
        # Prints an IP range.
        #
        # @param [String] ip_range
        #
        def print_ip_range(ip_range)
          ip_range = Support::Network::IPRange.new(ip_range)

          ip_range.each do |ip|
            puts ip
          end
        end

      end
    end
  end
end
