local geom = playdate.geometry

-- See OReilly AI for Game Developers
function vrotate2d(angle, uV)
    local x, y 

	x = uV.x * math.cos(math.rad(-angle)) + uV.y * math.sin(math.rad(-angle));
	y = -uV.x * math.sin(math.rad(-angle)) + uV.y * math.cos(math.rad(-angle));

	return geom.vector2d.new(x, y)
end