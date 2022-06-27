package flxanimate.animate;

import flixel.math.FlxMatrix;

class FlxInstance
{
	public static function prepareMatrix(m3d:Array<Float>)
	{
		return new FlxMatrix(m3d[0], m3d[1], m3d[4], m3d[5], m3d[12], m3d[13]);
	}
}