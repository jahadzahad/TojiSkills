--[[API DOCUMENTATION

---METHODS---

Lerping:
DarwinUtilities:Lerp(start : number, target : number, alpha : number) : number

Tweening:
DarwinUtilities::GetTweenValue(tweenData : GetTweenValue, func : (tweenValues : {number | CFrame | Vector3}) -> ()) : TweenBase

---HOW TO USE----

local tweenData : DarwinUtil.GetTweenValue = {
		Base = object, ---- preferabbly reference the part/model, if string or number make sure it unique for each tween's base
		TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		TweenConfiguration = {
			StartValues = {
				["Transparency"] = {0}, 
				["Colour"] = {Color.R, Color.G,Color.B} --- only for colour3 you need to separate but cframe and vector3 are fine
				["Position"] = {Vector3.new(0,0,0)}
			},
			TargetValues = {
				["Transparency"] = {0.8},
				["Colour"] = {0,0,0}
				["Position"] = {Vector3.new(10,10,10)}
			}
		}
	}
DarwinUtil:GetTweenValue(tweenData, function(tweenValues : {[string] : number | CFrame | Vector3})
	part.Transparency = tweenValues.Transparency[1]
	part.Color = Color3.fromRGB(tweenValues.Colour[1], tweenValues.Colour[2], tweenValues.Colour[3])
	part.Position = tweenValues.Position[1]
end)

]]--