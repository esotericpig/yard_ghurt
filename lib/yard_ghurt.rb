#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of YardGhurt.
# Copyright (c) 2019 Jonathan Bradley Whited (@esotericpig)
# 
# YardGhurt is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# YardGhurt is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with YardGhurt.  If not, see <https://www.gnu.org/licenses/>.
#++


require 'yard_ghurt/anchor_links'
require 'yard_ghurt/gfm_fix_task'
require 'yard_ghurt/ghp_sync_task'
require 'yard_ghurt/util'
require 'yard_ghurt/version'

###
# YARDoc GitHub Rake Tasks
# 
# @author Jonathan Bradley Whited (@esotericpig)
# @since  1.0.0
###
module YardGhurt
  # Internal code should use +Util.+!
  # See {Util} for details.
  include Util
end
