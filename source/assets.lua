-- From: https://devforum.play.date/t/best-practices-for-managing-lots-of-assets/395
Assets = {}

local images = {}
local imagetables = {}
local fonts = {}
local samples = {}

local unloadedImages = {}
local unloadedImagetables = {}
local unloadedFonts = {}
local unloadedSamples = {}

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

function Assets.preloadSamples(list)
	for i = 1, #list do
		local path = list[i]
		if not samples[path] then
			push(unloadedSamples, path)
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

local function getSample(path)
	if samples[path] then
		return samples[path]
	end
	local sample, err = snd.sample.new(path)
	assert(sample, err)
	samples[path] = sample
	return sample
end

Assets.getImage = getImage
Assets.getImagetable = getImagetable
Assets.getFont = getFont
Assets.getSample = getSample

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

	count = #unloadedSamples
	if count > 0 then
		for i = count, 1, -1 do
			getSample(pop(unloadedSamples))
			if outOfTime(frameStart) then return end
		end
	end
end
