local Types = {}

local tweenComponent = script.Parent

export type TweenDataTweenConfiguration = {
	StartValues : {
		[Properties] : NumberTypes | {NumberTypes}
	},
	TargetValues : {
		[Properties] : NumberTypes | {NumberTypes}
	},
}

export type TweenConfiguration = {
	[Properties] : NumberTypes | {NumberTypes}
}

export type StoredBase = {
	Active : boolean, 
	Connection : RBXScriptConnection,
	Thread : thread,
}

export type TweenData = {
	Base : string | number | BasePart | Model, -- preferably just refer the part/model, if you do the string or number make sure it unique for each tween
	TweenInfo : TweenInfo,
	TweenConfiguration : TweenDataTweenConfiguration
}

export type TweenValues = {
	Transparency : number | {number},
	Size : number | {number},
	Scale : number | {number},
	Colour : {number},
	Position : Vector3 | {Vector3},
	CFrame : CFrame | {CFrame}
}

export type TweenBase = typeof(require(tweenComponent.TweenBase))

return Types
