-- Jeff Sabol
-- 7/7/2025
-- Automating sand fall from pyramid tip to floor, while depleting the pyramid.
local sprite = app.activeSprite
if not sprite then
    return app.alert("No sprite found!")
end

local layer = sprite.layers[1]
local totalFrames = 1025
local sandColor = app.pixelColor.rgba(255, 163, 0, 255)
local emptyColor = app.pixelColor.rgba(255, 241, 232, 255)
local floorHeight = 26
local firstGrain = true

-- Initialize sand grains (upside down triangle)
local function initializeSandGrains()
    local grains = {}
    local leftX, rightX, lastX = 6, 22, 14
    local endHeight = 13

    for y = 5, endHeight do
        for x = leftX, rightX do
            grains[#grains + 1] = { x = x, y = y }
        end
        if leftX < lastX then leftX = leftX + 1 end
        if rightX > lastX then rightX = rightX - 1 end
    end

    return grains
end

local grains = initializeSandGrains()

-- Create all the frames
while #sprite.frames < totalFrames do
    sprite:newFrame()
end

-- Use the first frame
local firstCel = layer:cel(1)
local firstImage = firstCel and firstCel.image or Image(sprite.width, sprite.height, sprite.colorMode)

if not firstCel then
    for _, grain in ipairs(grains) do
        firstImage:putPixel(grain.x, grain.y, sandColor)
    end
    sprite:newCel(layer, sprite.frames[1], firstImage, Point(0, 0))
end

-- Initialize falling sand grain position tip
local fallingGrain = { x = 14, y = 13, lastDirection = "right" }

-- Clone grains (to track depletion)
local remainingGrains = {}
for i, g in ipairs(grains) do
    remainingGrains[i] = { x = g.x, y = g.y }
end

local pyramidIndex = 1 -- Start from the topmost grain

-- Animate frames
for frameIndex = 2, totalFrames do
    local prevCel = layer:cel(frameIndex - 1)
    local prevImage = prevCel.image
    local newImage = prevImage:clone()
    local nextDirection = "right"

    local canMove = true

    -- Erase old position
    newImage:putPixel(fallingGrain.x, fallingGrain.y, emptyColor)

    -- Check movement priority
    if fallingGrain.wait then
        fallingGrain.wait = false
    else
        if fallingGrain.y + 1 <= floorHeight and newImage:getPixel(fallingGrain.x, fallingGrain.y + 1) == emptyColor then
            -- Move straight down
            fallingGrain.y = fallingGrain.y + 1
        elseif firstGrain then
            -- If it's the first grain, don't allow side movement—just stop when can't move down
            canMove = false
        elseif fallingGrain.lastDirection == "right" then
            if fallingGrain.x + 1 < sprite.width and newImage:getPixel(fallingGrain.x + 1, fallingGrain.y + 1) == emptyColor then
                -- Move right & down
                fallingGrain.x = fallingGrain.x + 1
                fallingGrain.y = fallingGrain.y + 1
            elseif fallingGrain.x - 1 >= 0 and newImage:getPixel(fallingGrain.x - 1, fallingGrain.y + 1) == emptyColor then
                -- Move left & down as fallback
                fallingGrain.x = fallingGrain.x - 1
                fallingGrain.y = fallingGrain.y + 1
                fallingGrain.lastDirection = "left" -- switch
            else
                canMove = false
            end
        elseif fallingGrain.lastDirection == "left" then
            if fallingGrain.x - 1 >= 0 and newImage:getPixel(fallingGrain.x - 1, fallingGrain.y + 1) == emptyColor then
                -- Move left & down
                fallingGrain.x = fallingGrain.x - 1
                fallingGrain.y = fallingGrain.y + 1
            elseif fallingGrain.x + 1 < sprite.width and newImage:getPixel(fallingGrain.x + 1, fallingGrain.y + 1) == emptyColor then
                -- Move right & down as fallback
                fallingGrain.x = fallingGrain.x + 1
                fallingGrain.y = fallingGrain.y + 1
                fallingGrain.lastDirection = "right" -- switch
            else
                canMove = false
            end
        end
    end

    -- Draw new position
    newImage:putPixel(fallingGrain.x, fallingGrain.y, sandColor)

    -- If grain is stuck (can't move), spawn the next one
    if not canMove then
        if pyramidIndex <= #remainingGrains then
            local toErase = remainingGrains[pyramidIndex]
            newImage:putPixel(toErase.x, toErase.y, emptyColor)

            fallingGrain.x = 14
            fallingGrain.y = 13
            fallingGrain.lastDirection = "right"
            fallingGrain.wait = true

            -- Flip for next grain
            nextDirection = (nextDirection == "right") and "left" or "right"

            pyramidIndex = pyramidIndex + 1
            firstGrain = false
        end
    end

    sprite:newCel(layer, sprite.frames[frameIndex], newImage, Point(0, 0))
end

app.refresh()
