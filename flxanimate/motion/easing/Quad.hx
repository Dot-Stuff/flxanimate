package flxanimate.motion.easing;

class Quad implements BaseEase
{
	public static function easeIn(time:Float, initial:Float, total:Float, duration:Float):Float
	{
		return total * (time /= duration) * time + initial;
	}
	public static function easeOut(time:Float, initial:Float, total:Float, duration:Float):Float
	{
		return -total * (time /= duration) * (time - 2) + initial;
	}
	public static function easeInOut(time:Float, initial:Float, total:Float, duration:Float):Float
	{
		if ((time /= duration / 2) < 1)
			return total / 2 * time * time + initial;

		return -total / 2 * ((--time) * (time - 2) - 1) + initial;
	}
}