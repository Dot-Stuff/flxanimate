package flxanimate.motion.easing;

class Linear implements BaseEase
{
	public static function easeNone(time:Float, initial:Float, total:Float, duration:Float):Float
	{
		return total * time / duration + initial;
	}
	public static function easeIn(time:Float, initial:Float, total:Float, duration:Float):Float
	{
		return easeNone(time, initial, total, duration);
	}
	public static function easeOut(time:Float, initial:Float, total:Float, duration:Float):Float
	{
		return easeNone(time, initial, total, duration);
	}
	public static function easeInOut(time:Float, initial:Float, total:Float, duration:Float):Float
	{
		return easeNone(time, initial, total, duration);
	}
}
