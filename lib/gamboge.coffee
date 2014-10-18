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

GambogeView = require './gamboge-view'

module.exports =
  gambogeView: null

  activate: (state) ->
    @gambogeView = new GambogeView(state.gambogeViewState)

  deactivate: ->
    @gambogeView.destroy()

  # TODO: Do we need state serialization?
  serialize: ->
    gambogeViewState: @gambogeView.serialize()
