AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(table.Random(DMS.ForgeModels) or "models/props_forest/furnace01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then phys:Wake() end

    self.Stones = {}
    self.NextForge = 0
    self:SetNWBool("Processing", false)
    self:SetNWInt("ForgeTime", 0)
    self:SetNWFloat("ForgeEndTime", 0)
    self:SetNWString("CurrentIngot", "")
    self:SetNWBool("PoweredOn", false)  -- Default to powered off
    self.TouchCooldowns = {}
end

-- Process the next ore in the queue, if there is one
function ENT:ProcessNextOre()
    -- Ensure there are stones to process
    if #self.Stones == 0 then
        self:StopProcessing() -- Stop processing if no stones are left
        return
    end

    -- Get the next stone to process
    local oreName = self.Stones[1]
    local ingotData
    for _, ingot in ipairs(DMS.Ores.Ingots) do
        if ingot.name == oreName then
            ingotData = ingot
            break
        end
    end

    if ingotData then
        self:SetNWString("CurrentIngot", oreName)
        self:SetNWInt("ForgeTime", ingotData.forgetime)
        self:SetNWFloat("ForgeEndTime", CurTime() + ingotData.forgetime)
    end
end

-- Start processing ores if the machine is powered on and there are stones to process
function ENT:StartProcessing()
    -- Check if the machine is powered on and there are stones in the machine
    if not self:GetNWBool("PoweredOn") or #self.Stones == 0 then return end

    -- Only start processing if it's not already processing
    if self:GetNWBool("Processing") then return end

    self:SetNWBool("Processing", true)

    -- Play the starting sound
    self:EmitSound("ambient/fire/ignite.wav", 75, 100, 1, CHAN_STATIC)

    -- After the first sound finishes, play the loop sound
    timer.Simple(1.5, function() -- Adjust time based on how long the first sound plays
        if IsValid(self) then
            self:EmitSound("ambient/fire/fire_big_loop1.wav", 75, 100, 1, CHAN_LOOPING)
        end
    end)

    -- Set the forge time for the first stone in the queue
    self:ProcessNextOre()
end

-- Stop processing manually or automatically when the machine is empty
function ENT:StopProcessing()
    if not self:GetNWBool("Processing") then return end

    self:SetNWBool("Processing", false)

    -- Stop the starting sound when processing stops
    self:StopSound("ambient/fire/ignite.wav") 

    -- Stop the loop sound when processing stops
    self:StopSound("ambient/fire/fire_big_loop1.wav") 

    -- Clear the current ingot and forge time
    self:SetNWString("CurrentIngot", "")
    self:SetNWInt("ForgeTime", 0)
    self:SetNWFloat("ForgeEndTime", 0)
end

-- Complete the processing for the current ore and output the ingot
function ENT:CompleteProcessing()
    local oreName = self.Stones[1]
    local ingotData
    for _, ingot in ipairs(DMS.Ores.Ingots) do
        if ingot.name == oreName then
            ingotData = ingot
            break
        end
    end

    if ingotData then
        -- Create the ingot entity
        local ent = ents.Create("dubz_ingot")
        if not IsValid(ent) then return end

        ent:SetModel(ingotData.model or "models/props_lab/reciever_cart.mdl")
        ent:SetColor(ingotData.color or color_white)

        local ang = self:GetAngles()

        -- Spawn position: slightly in front + slightly down
        local spawnPos =
            self:GetPos() +
            ang:Forward() * 25 +    -- adjust this forward distance
            ang:Up() * 10         -- same height offset you used

        ent:SetPos(spawnPos)
        ent:SetAngles(ang)           -- optional: match furnace rotation
        ent:SetNWString("OreName", oreName)
        ent:Spawn()

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetVelocity(ang:Forward() * 30)  -- small push outward
        end

        -- Sound effects
        self:EmitSound("ambient/machines/metal_scrap1.wav")
        self:EmitSound("ambient/fire/gascan_ignite2.wav", 75, 100, 1, CHAN_STATIC)
    end

    -- Remove the processed stone from the queue
    table.remove(self.Stones, 1)

    -- Continue processing if there are still stones in the queue
    if #self.Stones > 0 then
        self:ProcessNextOre()
    else
        self:StopProcessing()
    end
end

function ENT:GetForgeTime(name)
    for _, data in ipairs(DMS.Ores.Ingots) do
        if data.name == name then return data.forgetime end
    end
    return nil
end

-- Finish processing the ore and create the ingot
function ENT:FinishForging(ingotData)
    -- Forge the ingot
    local ingot = ents.Create("dubz_ingot")  -- Create the ingot entity
    if IsValid(ingot) then
        ingot:SetPos(self:GetPos() + Vector(0, 0, 20))  -- Place the ingot near the forge
        ingot:SetNWString("IngotName", ingotData.name)
        ingot:SetNWInt("IngotValue", ingotData.price)  -- Set the value of the ingot
        ingot:Spawn()

        -- Stop the sound when done
        self:StopSound("ambient/machines/combine_terminal_idle1.wav")

        -- Update the processing status and power state
        self:SetNWBool("Processing", false)
        self:SetNWBool("PoweredOn", false)  -- Power off after processing

        -- Stop the starting sound when processing stops
        self:StopSound("ambient/fire/ignite.wav") 

        -- Stop the loop sound when processing stops
        self:StopSound("ambient/fire/fire_big_loop1.wav") 

        -- You could optionally emit a sound when the processing is complete
        self:EmitSound("ambient/fire/gascan_ignite2.wav")
    end
end

function ENT:IsValidOre(name)
    for _, data in ipairs(DMS.Ores.Ingots) do
        if data.name == name then return true end
    end
    return false
end

-- Toggle the machine's power by pressing E
function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local poweredOn = self:GetNWBool("PoweredOn")
    self:SetNWBool("PoweredOn", not poweredOn)

    if self:GetNWBool("PoweredOn") then
        -- Start processing when power is turned on, and a stone is added
        self:StartProcessing()  -- Call StartProcessing when powered on

        self:EmitSound("buttons/button9.wav") -- Power on confirm click
    else
        self:EmitSound("buttons/button14.wav") -- Power off confirm click

        -- Stop processing when power is turned off
        self:SetNWBool("Processing", false)
        -- Stop the starting sound when processing stops
        self:StopSound("ambient/fire/ignite.wav") 

        -- Stop the loop sound when processing stops
        self:StopSound("ambient/fire/fire_big_loop1.wav") 
    end
end

function ENT:StartTouch(ent)
    if not IsValid(ent) then return end

    -- Carts
    if ent:GetClass() == "dubz_cart" and ent.PullStones then
        local ores = ent:PullStones()
        for _, oreName in ipairs(ores) do
            if self:IsValidOre(oreName) then
                table.insert(self.Stones, oreName)
                self:EmitSound("physics/metal/metal_box_impact_soft1.wav")

                -- Start processing automatically if the machine is powered on
                if self:GetNWBool("PoweredOn") then
                    self:StartProcessing()
                end
            end
        end
        return
    end

    -- Loose stones
    if ent:GetClass() ~= "dubz_stone" then return end

    local id = ent:EntIndex()
    self.TouchCooldowns[id] = self.TouchCooldowns[id] or 0
    if CurTime() < self.TouchCooldowns[id] then return end
    self.TouchCooldowns[id] = CurTime() + 0.5

    local oreName = ent:GetNWString("OreName")
    if self:IsValidOre(oreName) then
        table.insert(self.Stones, oreName)
        self:EmitSound("physics/metal/metal_box_impact_soft1.wav")

        -- Start processing automatically if the machine is powered on
        if self:GetNWBool("PoweredOn") then
            self:StartProcessing()
        end
        ent:Remove()
    end
end

-- Perform actions every frame, checking processing status
function ENT:Think()
    if self:GetNWBool("Processing") then
        local timeRemaining = self:GetNWFloat("ForgeEndTime") - CurTime()

        if timeRemaining <= 0 then
            -- Ingot is fully processed, spawn the ingot and continue processing if more stones are available
            self:CompleteProcessing()
        else
            self:SetNWInt("ForgeTime", math.ceil(timeRemaining))
        end
    end

    self:NextThink(CurTime())
    return true
end

function ENT:OnRemove()
end