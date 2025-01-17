package flxanimate.motion.easing;

/**
 * The template to create your own easing methods.
 */
interface BaseEase
{
	public static function easeIn(time:Float, initial:Float, total:Float, duration:Float):Float
	public static function easeOut(time:Float, initial:Float, total:Float, duration:Float):Float
	public static function easeInOut(time:Float, initial:Float, total:Float, duration:Float):Float
}