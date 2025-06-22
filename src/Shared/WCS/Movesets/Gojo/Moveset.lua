local ReplicatedStorage = game:GetService( 'ReplicatedStorage' )

local Skills = ReplicatedStorage.Shared.WCS.Movesets.Gojo.Skills

local WCS = require( ReplicatedStorage.Packages.WCS )

return WCS.CreateMoveset(
	'Gojo',
	{
		require( Skills[ 'Infinity Grab' ] ),
	}
)