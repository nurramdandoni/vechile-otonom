-- Assigns obstacle value to nodes as defined by
-- include/extractor/obstacles.hpp

local Obstacles = {}

Obstacles.obstacle_type = {
  barrier = 1,
  stop = 2,
  stop_minor = 3,
  give_way = 4,
  traffic_signals = 5
}

Obstacles.obstacle_direction = {
  none = 0,
  forward = 1,
  backward = 2,
  both = 3
}

function Obstacles.new(type, direction, duration, weight)
  return {
    type = type,
    direction = direction or Obstacles.obstacle_direction.none,
    duration = duration or 0,
    weight = weight or 0
  }
end

function Obstacles.process_node(profile, node)
  local highway = node:get_value_by_key("highway")
  if highway then
    local type = Obstacles.obstacle_type[highway]
    -- barriers already handled in car.lua
    if type and type ~= Obstacles.obstacle_type.barrier then
      local direction = node:get_value_by_key("direction")
      local weight = 0
      local duration = 0

      if type == Obstacles.obstacle_type.traffic_signals then
        direction = node:get_value_by_key("traffic_signals:direction") or direction
        duration = profile.properties.traffic_signal_penalty or 2
      elseif type == Obstacles.obstacle_type.stop then
        if node:get_value_by_key("stop") == "minor" then
          type = Obstacles.obstacle_type.stop_minor
        end
        duration = 2
      elseif type == Obstacles.obstacle_type.give_way then
        duration = 1
      end

      obstacle_map:add(node, Obstacles.new(type, Obstacles.obstacle_direction[direction] or Obstacles.obstacle_direction.none, duration, weight))
    end
  end
end

function Obstacles.entering_by_minor_road(turn)
  local max_speed = turn.target_speed
  for _, turn_leg in pairs(turn.roads_on_the_right) do
    max_speed = math.max(max_speed, turn_leg.speed)
  end
  for _, turn_leg in pairs(turn.roads_on_the_left) do
    max_speed = math.max(max_speed, turn_leg.speed)
  end
  return max_speed > turn.source_speed
end

return Obstacles
