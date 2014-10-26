# Copyright (C) 2014  Eddie Antonio Santos
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module.exports =
  unnaturalRESTOrigin:
    title: 'UnnaturaREST Origin URL'
    type: 'string'
    default: 'localhost:5000'

  # TODO: Should I rip-off Autocomplete+ like this?
  enableAutoGhostText:
    type: 'boolean'
    description: "Automatically display first suggestion after a
                  configurable delay."
    default: yes
  autoGhostTextDelay:
    type: 'integer'
    min: 0
    default: 100
  dedentMarker:
    type: 'string'
    description: "Character to display when Gamboge suggests a decrease in
                  indentation for indentation-sensitive languages such as
                  Python, CoffeeScript, Haskell, etc."
    default: '«'

