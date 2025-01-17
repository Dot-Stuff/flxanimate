package flxanimate.geom;

import flixel.math.FlxMatrix;
import openfl.Vector;
import openfl.geom.Matrix;
import openfl.geom.Matrix3D;

/**
 * `FlxMatrix3D` consists of `openfl.geom.Matrix3D` but with a new naming plus some new functions/variables that are convenient to FlxAnimate.
 */
class FlxMatrix3D extends Matrix3D
{
	public function new(?v:Vector<Float> = null)
	{
		super(v);
	}
	public function concat2D(m:Matrix)
	{
		var a = rawData[0];
		var b = rawData[1];
		var c = rawData[4];
		var d = rawData[5];
		var tx = rawData[12];
		var ty = rawData[13];

		var a1 = a * m.a + b * m.c;
		b = a * m.b + b * m.d;
		a = a1;

		var c1 = c * m.a + d * m.c;
		d = c * m.b + d * m.d;
		c = c1;

		var tx1 = tx * m.a + ty * m.c + m.tx;
		ty = tx * m.b + ty * m.d + m.ty;
		tx = tx1;
	}

	public function toString()
	{
		return rawData.toString();
	}
	public function toMatrix()
	{
		return new FlxMatrix(rawData[0], rawData[1], rawData[4], rawData[5], rawData[12], rawData[13]);
	}

	public static function fromMatrix(m:FlxMatrix)
	{
		return new FlxMatrix3D(new Vector([m.a, m.b, 0.0, m.c, m.d, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, m.tx, m.ty, 0.0, 0.0, 1.0]));
	}

	public override function clone() {
		return new FlxMatrix3D(rawData.copy());
	}
}