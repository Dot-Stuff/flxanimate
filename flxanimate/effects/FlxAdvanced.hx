package flxanimate.effects;

import openfl.geom.ColorTransform;

@:access(openfl.geom.ColorTransform)
class FlxAdvanced extends FlxColorEffect
{
	public var colorTransform(get, set):ColorTransform;

	public function new(colorTransform:ColorTransform)
	{
		super();
		this.colorTransform = colorTransform;
	}

	inline function get_colorTransform()
	{
		return c_Transform;
	}
	function set_colorTransform(value:ColorTransform)
	{
		c_Transform.__copyFrom(value);
		//c_Transform.redMultiplier = value.redMultiplier;
		//c_Transform.greenMultiplier = value.greenMultiplier;
		//c_Transform.blueMultiplier = value.blueMultiplier;
		//c_Transform.alphaMultiplier = value.alphaMultiplier;

		//c_Transform.redOffset = value.redOffset;
		//c_Transform.greenOffset = value.greenOffset;
		//c_Transform.blueOffset = value.blueOffset;
		//c_Transform.alphaOffset = value.alphaOffset;
		return value;
	}
}