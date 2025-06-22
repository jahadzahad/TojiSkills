local types = {}

export type Properties = "Transparency" | 
"Colour" | 
"Size" | 
"Scale" | 
"Position" | 
"CFrame" | 
"BackgroundTransparency" |
"ImageTransparency" | 
"TextTransparency"

export type NumberTypes = number | Vector3 | CFrame | NumberSequence | ColorSequence
export type Keypoint = typeof(NumberSequence.new().Keypoints[1])

export type CoreCallMethods = "GetCoreGuiEnabled" | "SetCore" | "SetCoreGuiEnabled" | "GetCore"

export type CoreGuiType = "ResetButtonCallback" |
"PointsNotificationsActive" |
"BadgesNotificationsActive" |
"AvatarContextMenuEnabled" | 
"ChatActive" |
"ChatWindowSize" |
"ChatWindowPosition" |
"ChatBarDisabled" |
"GetBlockedUserIds" |
"PlayerBlockedEvent" |
"PlayerUnblockedEvent" |
"PlayerMutedEvent" |
"PlayerUnmutedEvent" |
"PlayerFriendedEvent" |
"PlayerUnfriendedEvent" |
"DevConsoleVisible" |
"VRRotationIntensity" |

export type TweenData = {
	Base : string | number | BasePart | Model, -- preferably just refer the part/model, if you do the string or number make sure it unique for each tween
	TweenInfo : TweenInfo,
	TweenConfiguration :{ 
		StartValues : {
			[Properties] : NumberTypes | {NumberTypes}
		},
		TargetValues : {
			[Properties] : NumberTypes | {NumberTypes}
		},
	}
}

export type FovProperties = {
	Start : number,
	End : number,
}

export type TweenInfosFov = {
	Start : TweenInfo,
	End : TweenInfo,
}

export type CallBackTweenFov = {
	Start : TweenBase,
	End : TweenBase,
}

export type MouseResult = {
	Hit : CFrame,
	Target : RaycastResult,
}

export type IgnoreListVFX = {
	[number] : "Beam" | "Trail" | "ParticleEmitter"
}

export type VisualParams = {
	IgnoreList : IgnoreListVFX,
	Destroy : boolean,
}

export type TweenValues = {
	Transparency : number | {number},
	Size : number | {number},
	Scale : number | {number},
	Colour : {number},
	Position : Vector3 | {Vector3},
	CFrame : CFrame | {CFrame}
}

export type HeadTrackParams = {
	Condition : "Start"? | "End"?,
	OriginOffset : Vector3?,
	TargetOffset : Vector3?,
	Movement : boolean,
	Override : boolean,
}

export type DirectionOptions = "Forward-Left" |
"Forward-Right" |
"Backward-Right" |
"Backward-Left" |
"Forward" |
"Backward" |
"Right" |
"Left"

export type GetDirectionConfig = {
	Diagonal : boolean?,
	Offset : Vector3?
}

return types
