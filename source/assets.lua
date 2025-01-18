-- From: https://devforum.play.date/t/best-practices-for-managing-lots-of-assets/395
Assets = {}

local images = {}
local imagetables = {}
local fonts = {}
local samplePlayers = {}

local unloadedImages = {}
local unloadedImagetables = {}
local unloadedFonts = {}
local unloadedSamplePlayers = {}

local push = table.insert
local pop = table.remove

function Assets.preloadImages(list)
	for i = 1, #list do
		local path = list[i]
		if not images[path] then
			push(unloadedImages, path)
		end
	end
end

function Assets.preloadImagetables(list)
	for i = 1, #list do
		local path = list[i]
		if not imagetables[path] then
			push(unloadedImagetables, path)
		end
	end
end

function Assets.preloadFonts(list)
	for i = 1, #list do
		local path = list[i]
		if not fonts[path] then
			push(unloadedFonts, path)
		end
	end
end

function Assets.preloadSamplePlayers(list)
	for i = 1, #list do
		local path = list[i]
		if not samples[path] then
			push(unloadedSamplePlayers, path)
		end
	end
end

------------------------

local ms = playdate.getCurrentTimeMilliseconds
local gfx = playdate.graphics
local snd = playdate.sound

local function getImage(path)
	if images[path] then
		return images[path]
	end
	local image, err = gfx.image.new(path)
	assert(image, err)
	images[path] = image
	return image
end

local function getImagetable(path)
	if imagetables[path] then
		return imagetables[path]
	end
	local imagetable, err = gfx.imagetable.new(path)
	assert(imagetable, err)
	imagetables[path] = imagetable
	return imagetable
end

local function getFont(path)
	if fonts[path] then
		return fonts[path]
	end
	local font, err = gfx.font.new(path)
	assert(font, err)
	fonts[path] = font
	return font
end

local function getSamplePlayer(path)
	if samplePlayers[path] then
		return samplePlayers[path]
	end
	local samplePlayer, err = snd.sampleplayer.new(path)
	assert(samplePlayer, err)
	samplePlayers[path] = samplePlayer
	return samplePlayer
end

Assets.getImage = getImage
Assets.getImagetable = getImagetable
Assets.getFont = getFont
Assets.getSamplePlayer = getSamplePlayer

------------------------

local frameDuration
local function outOfTime(frameStart)
	return (ms() - frameStart) >= frameDuration
end
function Assets.lazyLoad(frameStart)
	if not frameDuration then
		frameDuration = math.floor(1000 / playdate.display.getRefreshRate()) -- only called once
	end

	local count

	count = #unloadedFonts
	if count > 0 then
		for i = count, 1, -1 do
			getFont(pop(unloadedFonts))
			if outOfTime(frameStart) then return end
		end
	end

	count = #unloadedImages
	if count > 0 then
		for i = count, 1, -1 do
			getImage(pop(unloadedImages))
			if outOfTime(frameStart) then return end
		end
	end

	count = #unloadedImagetables
	if count > 0 then
		for i = count, 1, -1 do
			getImagetable(pop(unloadedImagetables))
			if outOfTime(frameStart) then return end
		end
	end

	count = #unloadedSamplePlayers
	if count > 0 then
		for i = count, 1, -1 do
			getSamplePlayer(pop(unloadedSamplePlayers))
			if outOfTime(frameStart) then return end
		end
	end
end
