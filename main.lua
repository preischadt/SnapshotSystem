local Snapshot = require("Snapshot")
local DummyObject = require("DummyObject")

local snapshot = Snapshot:new()
for _=1,2 do
    local object = DummyObject:new()
    snapshot:addObject(object)
end

Runtime:addEventListener("key", function(event)
    if event.phase=="down" then
        if event.keyName=="left" then
            snapshot:goBack()
        elseif event.keyName=="right" then
            snapshot:goForward()
        end
    end
end)