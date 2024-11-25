---@diagnostic disable: duplicate-set-field

Callbacks = {}

Callbacks.requests = {}
Callbacks.storage = {}
Callbacks.id = 0

function Callbacks:Register(name, cb)
    self.storage[name] = cb
end

function Callbacks:Execute(cb, ...)
    local success, errorString = pcall(cb, ...)

    if not success then
        print(("[^1ERROR^7] Failed to execute Callback with RequestId: ^5%s^7"):format(self.currentId))
        error(errorString)
        return
    end
    self.currentId = nil
end

function Callbacks:Trigger(player, event, cb, invoker, ...)
    self.requests[self.id] = cb

    TriggerClientEvent("esx:triggerClientCallback", player, event, self.id, invoker, ...)

    self.id += 1
end

function Callbacks:ServerRecieve(player, event, requestId, invoker, ...)
    self.currentId = requestId

    if not self.storage[event] then
        return error(("Server Callback with requestId ^5%s^1 Was Called by ^5%s^1 but does not exist."):format(event, invoker))
    end

    local returnCb = function(...)
        TriggerClientEvent("esx:serverCallback", player, requestId, invoker, ...)
    end
    local callback = self.storage[event]

    self:Execute(callback, player, returnCb, ...)
end

function Callbacks:RecieveClient(requestId, invoker, ...)
    self.currentId = requestId

    if not self.requests[self.currentId] then
        return error(("Client Callback with requestId ^5%s^1 Was Called by ^5%s^1 but does not exist."):format(self.currentId, invoker))
    end

    local callback = self.requests[self.currentId]

    self:Execute(callback, ...)
    self.requests[requestId] = nil
end

RegisterNetEvent("esx:clientCallback", function(requestId, invoker, ...)
    Callbacks:RecieveClient(requestId, invoker, ...)
end)

RegisterNetEvent("esx:triggerServerCallback", function(eventName, requestId, invoker, ...)
    local source = source
    Callbacks:ServerRecieve(source, eventName, requestId, invoker, ...)
end)


---@param player number playerId
---@param eventName string
---@param callback function
---@param ... any
function ESX.TriggerClientCallback(player, eventName, callback, ...)
    local invokingResource = GetInvokingResource()
    local invoker = (invokingResource and invokingResource ~= "unknown") and invokingResource or "es_extended"

    Callbacks:Trigger(player, eventName, callback, invoker, ...)
end

---@param eventName string
---@param callback function
function ESX.RegisterServerCallback(eventName, callback)
    Callbacks:Register(eventName, callback)
end

---@param eventName string
---@return boolean
function ESX.DoesServerCallbackExist(eventName)
    return Callbacks.storage[eventName] ~= nil
end

---@param eventName string
---@return table | nil
function ESX.GetServerCallbackInfo(eventName)
    return Callbacks.storage[eventName]
end
