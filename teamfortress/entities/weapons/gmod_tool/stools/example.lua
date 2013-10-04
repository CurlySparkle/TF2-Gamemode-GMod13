
-- Remove this to add it to the menu
TOOL.AddToMenu		= false

-- Define these!
TOOL.Category		= "My Category"		-- Name of the category
TOOL.Name			= "#Example"		-- Name to display
TOOL.Command		= nil				-- Command on click (nil for default)
TOOL.ConfigName		= nil				-- Config file name (nil for default)

if ( true ) then return end


-- An example clientside convar
TOOL.ClientConVar["CLIENTSIDE"] = "default"

-- An example serverside convar
TOOL.ServerConVar["SERVERSIDE"] = "default"

function TOOL:LeftClick( trace )
	Msg( "PRIMARY FIRE\n" )
end

function TOOL:RightClick( trace )
	Msg( "ALT FIRE\n" )
end

function TOOL:Reload( trace )
	-- The SWEP doesn't reload so this does nothing :(
	Msg( "RELOAD\n" )
end

function TOOL:Think()
end