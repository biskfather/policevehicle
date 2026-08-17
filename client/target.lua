--[[
    Target wrapper.

    Supports both target resources so the script works on either setup:
      * ox_target  -> https://github.com/TheOrderFivem/ox_target (qb-core compatible fork)
      * qb-target  -> legacy qb-target

    Which one is used is controlled by Config.Target ('auto' by default).
]]

Target = {}

local resourceName = nil

---Returns true when a resource is started (or currently starting).
---@param name string
---@return boolean
local function isStarted(name)
    local state = GetResourceState(name)
    return state == 'started' or state == 'starting'
end

---Resolves which target resource should be used.
---@return string?
local function resolveTarget()
    local configured = Config.Target and string.lower(Config.Target) or 'auto'

    if configured ~= 'auto' then
        if not isStarted(configured) then
            print(('[policevehicle] Config.Target is set to "%s" but that resource is not started.'):format(configured))
        end

        return configured
    end

    -- ox_target takes priority, qb-target is the fallback.
    if isStarted('ox_target') then return 'ox_target' end
    if isStarted('qb-target') then return 'qb-target' end

    print('[policevehicle] No supported target resource found (ox_target / qb-target).')

    return nil
end

---@return string?
function Target.getResource()
    if resourceName == nil then
        resourceName = resolveTarget() or false
    end

    return resourceName or nil
end

---Adds a target option to a locally created (non-networked) entity.
---@param entity number
---@param data { name: string, label: string, icon: string?, distance: number?, onSelect: fun(entity: number) }
function Target.addLocalEntity(entity, data)
    local target = Target.getResource()
    if not target then return end

    local distance = data.distance or 2.0
    local icon = data.icon or 'fa-solid fa-car'

    if target == 'ox_target' then
        exports.ox_target:addLocalEntity(entity, {
            {
                name = data.name,
                icon = icon,
                label = data.label,
                distance = distance,
                onSelect = data.onSelect
            }
        })
    elseif target == 'qb-target' then
        exports['qb-target']:AddTargetEntity(entity, {
            options = {
                {
                    num = 1,
                    icon = icon,
                    label = data.label,
                    action = data.onSelect
                }
            },
            distance = distance
        })
    end
end

---Removes the previously added target option from an entity.
---@param entity number
---@param data { name: string, label: string }
function Target.removeLocalEntity(entity, data)
    local target = Target.getResource()
    if not target then return end

    if target == 'ox_target' then
        exports.ox_target:removeLocalEntity(entity, data.name)
    elseif target == 'qb-target' then
        exports['qb-target']:RemoveTargetEntity(entity, data.label)
    end
end
