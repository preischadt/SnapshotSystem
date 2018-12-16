local Utils = require("Utils")

local DummyObject = Utils.createClass({

},
function(self)
    self.displayObject = display.newRect(math.random(0, display.contentWidth), math.random(0, display.contentHeight), 100, 100)
    self.displayObject:addEventListener("touch", self)
    self.displayObject:setFillColor(math.random()*0.5+0.5, math.random()*0.5+0.5, math.random()*0.5+0.5)
end)

function DummyObject:getState()
    return {
        x = self.displayObject.x,
        y = self.displayObject.y,
    }
end

function DummyObject:setState(state)
    self.displayObject.x = state.x
    self.displayObject.y = state.y
end

function DummyObject:touch(event)
    self:setState({
        x = event.x,
        y = event.y,
    })
    Utils.notify({self, "changed"})
end

return DummyObject