local Utils = require("Utils")

local Snapshot = Utils.createClass({

},
function(self)
    self.objects = {}
    self.snaps = {{}}
    self.previousStates = {}
    self.changedSet = {}
    self.currentSnap = 1
end)

function Snapshot:addObject(object)
    --insert in objects list
    table.insert(self.objects, object)

    --listen to changed event
    Utils.listen({object, "changed"}, self.onObjectChanged, self)

    --add to changed list so that its initial state will be saved
    self.changedSet[object] = true
end

function Snapshot:onObjectChanged(event)
    --mark object as changed to save when snap is advanced
    local object = event[1]
    self.changedSet[object] = true
end

function Snapshot:hasChanges()
    --if has any objects in the changed set, then has at least one change
    for _ in pairs(self.changedSet) do
        return true
    end
    return false
end

function Snapshot:goBack()
    --cancel if there is not a previous snap
    if self.currentSnap==1 then
        return
    end

    --save changed objects
    local snap = self.snaps[self.currentSnap]
    for object in pairs(self.changedSet) do
        --save current state
        local currentState = object:getState()
        snap[object] = {
            currentState = currentState,
            previousState = self.previousStates[object]
        }
    end
    self.changedSet = {}

    --restore to previous states
    for object, objectSnap in pairs(snap) do
        object:setState(objectSnap.previousState)
    end

    --regress snap index
    self.currentSnap = self.currentSnap - 1
    local previousSnap = self.snaps[self.currentSnap]

    --set previous states
    for object, objectSnap in pairs(previousSnap) do
        self.previousStates[object] = objectSnap.previousState
    end
end

function Snapshot:goForward()
    --cancel if there are no changes nor a next snap
    if not self:hasChanges() and not self.snaps[self.currentSnap+1] then
        return
    end

    --save changed objects
    local snap = self.snaps[self.currentSnap]
    for object in pairs(self.changedSet) do
        --save current state
        local currentState = object:getState()
        snap[object] = {
            currentState = currentState,
            previousState = self.previousStates[object]
        }

        --setup previous state for next snap
        self.previousStates[object] = currentState
    end
    self.changedSet = {}

    --advance snap index
    self.currentSnap = self.currentSnap + 1
    local nextSnap = self.snaps[self.currentSnap]
    if nextSnap then
        --if there is a next snap, restore object states to it
        for object, objectSnap in pairs(nextSnap) do
            objectSnap.previousState = object:getState()
            object:setState(objectSnap.currentState)
        end
    else
        --otherwise, create snap
        self.snaps[self.currentSnap] = {}
    end
end

return Snapshot