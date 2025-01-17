package flxanimate.effects;

class FlxAlpha extends FlxColorEffect
{
	public var alpha(default, set):Float;

	public function new(alpha:Float)
	{
		this.alpha = alpha;

		super();
	}

	override function process()
	{
		c_Transform.alphaMultiplier = alpha;
	}
	function set_alpha(value:Float)
	{
		if (alpha != value) renderDirty = true;

		return alpha = value;
	}
}