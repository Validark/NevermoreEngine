--- Provides a basis for the compass GUI. Invidiual CompassElements handle
-- the positioning.
-- @classmod ICompass

local ICompass = {}
ICompass.__index = ICompass
ICompass.ClassName = "ICompass"
ICompass.PercentSolid = 0.8
ICompass.ThetaVisible = math.pi/2

function ICompass.new(CompassModel, Container)
	--- Makes a skyrim style "strip" compass.
	-- @param CompassModel A CompassModel to use for this compass
	-- @param Container A ROBLOX GUI to use as a container

	local self = setmetatable({}, ICompass)

	-- Composition
	self.CompassModel = CompassModel or error("No CompassModel")
	self.Container = Container or error("No Container")

	self.Elements = {}

	return self
end

--- Sets the percentage of the compass that is solid (that is, visible), to the player
-- This way, we can calculate transparency
-- @param PercentSolid Number [0, 1] of the percentage solid fo the compass element.
function ICompass:SetPercentSolid(PercentSolid)

	self.PercentSolid = tonumber(PercentSolid) or error("No PercentSolid")

	for Element, _ in pairs(self.Elements) do
		Element:SetPercentSolid(self.PercentSolid)
	end
end

--- Sets the area shown by the compass (the rest will be hidden). (In radians).
-- @param ThetaVisible Number [0, 6.28...] The theta in radians visible to the player overall.
function ICompass:SetThetaVisible(ThetaVisible)

	self.ThetaVisible = tonumber(ThetaVisible) or error("No or invalid ThetaVisible sent")
	assert(ThetaVisible > 0, "ThetaVisible must be > 0")

	for Element, _ in pairs(self.Elements) do
		Element:SetThetaVisible(self.ThetaVisible)
	end
end

---
-- @param Element An ICompassElement to be added to the system
function ICompass:AddElement(Element)

	assert(not self.Elements[Element], "Element already added")

	self.Elements[Element] = true
	Element:SetPercentSolid(self.PercentSolid)
	Element:SetThetaVisible(self.ThetaVisible)

	Element:GetGui().Parent = self.Container
end

--- Calculates the GUI position for the element
-- @param PercentPosition Number, the percent position to use
-- @return UDim2 The position (center) of the GUI element given its percentage. Relative to the container.
-- @return [Rotation] Number in degrees, the rotation of the GUI to be set.
function ICompass:GetPosition(PercentPosition)

	error("GetPosition is not overridden yet")
end

--- Updates the compass for fun!
function ICompass:Draw()
	self.CompassModel:Step()

	for Element, _ in pairs(self.Elements) do
		local PercentPosition = Element:CalculatePercentPosition(self.CompassModel)
		Element:SetPercentPosition(PercentPosition)

		local NewPosition, NewRotation = self:GetPosition(PercentPosition)
		Element:SetPosition(NewPosition)
		if NewRotation then
			Element:SetRotation(NewRotation)
		end
		Element:Draw()
	end
end

return ICompass