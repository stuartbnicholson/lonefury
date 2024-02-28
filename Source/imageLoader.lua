local gfx = playdate.graphics

function loadImage(imagePath)
    local img, err = gfx.image.new(imagePath)
    if img ~= nil then
        print('loaded ' .. imagePath)
    else
        print('nil image? ' .. err)
    end
    
    return img
end