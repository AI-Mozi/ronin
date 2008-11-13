#
#--
# Ronin - A Ruby platform designed for information security and data
# exploration tasks.
#
# Copyright (c) 2006-2008 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#++
#

require 'set'

module Ronin
  module Chars
    class CharSet < Array

      #
      # Creates a new CharSet object with the given _chars_.
      #
      def initialize(*chars)
        format_char = lambda { |char|
          if (char.kind_of?(Array) || char.kind_of?(Range))
            char.map(&format_char)
          elsif char.kind_of?(Integer)
            char.chr
          else
            char.to_s
          end
        }

        super(chars.map(&format_char).flatten.uniq)
      end

      #
      # Returns +true+ if the character set contains the specified _char_,
      # returns +false+ otherwise. The specified _char_ can be either an
      # Integer or a String.
      #
      def include?(char)
        if char.kind_of?(Integer)
          return super(char.chr)
        else
          return super(char)
        end
      end

      #
      # Create a new CharSet object containing the characters that match
      # the given _block_.
      #
      def select(&block)
        CharSet.new(super(&block))
      end

      #
      # Creates a new CharSet object by passing each character to the
      # specified _block_.
      #
      def map(&block)
        CharSet.new(super(&block))
      end

      #
      # Returns a random char from the character set.
      #
      def random_char
        self[rand(self.length)]
      end

      #
      # Pass a random character to the specified _block_, _n_ times.
      #
      def each_random_char(n,&block)
        n.to_i.times { block.call(random_char) }
      end

      #
      # Returns an Array of the specified _length_ containing
      # random characters from the character set.
      #
      def random_array(length)
        if length.kind_of?(Range)
          return Array.new(length.sort_by { rand }.first) { random_char }
        else
          return Array.new(length.to_i) { random_char }
        end
      end

      #
      # Returns a String of the specified _length_ containing
      # random characters from the character set.
      #
      def random_string(length)
        random_array(length).join
      end

      #
      # Returns +true+ if the specified _other_set_ contains the same
      # set of characters as the character set, returns +false+ otherwise.
      #
      def ==(other_set)
        self.to_set == other_set.to_set
      end

      #
      # Return a new CharSet that is the union of the character set and the
      # specified _other_set_.
      #
      def |(other_set)
        CharSet.new(self | other_set)
      end

      alias + |

      #
      # Returns a new CharSet that is the intersection of the character set
      # and the specified _other_set_.
      #
      def -(other_set)
        CharSet.new(super(other_set.to_a))
      end

    end
  end
end
