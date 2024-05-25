package flxanimate.motion.easing;

class Sine implements BaseEase
{
	public static function easeIn(time:Float, initial:Float, total:Float, duration:Float):Float
	{
		return -total * Math.cos(time / duration * (Math.PI / 2)) + total + initial;
	}
	public static function easeOut(time:Float, initial:Float, total:Float, duration:Float):Float
	{
		return total * Math.sin(time / duration * (Math.PI / 2)) + initial;
	}
	public static function easeInOut(time:Float, initial:Float, total:Float, duration:Float):Float
	{
		return -total / 2 * (Math.cos(Math.PI * time / duration) - 1) + initial;
	}
}