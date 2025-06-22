local ReplicatedStorage = game:GetService( 'ReplicatedStorage' )

local Skills = ReplicatedStorage.Shared.WCS.Movesets.Enel.Skills

local WCS = require( ReplicatedStorage.Packages.WCS )

return WCS.CreateMoveset(
	'Enel',
	{
		require( Skills[ 'El Thor' ] ),
		require( Skills[ 'Celestial Blitz' ] ),
	}
)