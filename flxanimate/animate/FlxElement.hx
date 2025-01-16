package flxanimate.animate;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.FlxObject;
import flxanimate.geom.FlxMatrix3D;
import flixel.math.FlxPoint;
import flxanimate.data.AnimationData;
import flixel.math.FlxMatrix;
import openfl.geom.ColorTransform;
import flixel.graphics.frames.FlxFrame;
import flixel.FlxCamera;

@:access(flxanimate.animate.SymbolParameters)
class FlxElement extends FlxObject implements IFlxDestroyable
{
	@:allow(flxanimate.animate.FlxKeyFrame)
	var _parent:FlxKeyFrame;
	/**
	 * All the other parameters that are exclusive to the symbol (instance, type, symbol name, etc.)
	 */
	public var symbol(default, null):SymbolParameters = null;
	/**
	 * The name of the bitmap itself.
	 */
	public var bitmap(default, set):String;
	/**
	 * The matrix that the symbol or bitmap has.
	 * **WARNING** The positions here are constant, so if you use `x` or `y`, this will concatenate to the matrix,
	 * not replace it!
	 */
	public var matrix(default, set):FlxMatrix;

	@:allow(flxanimate.FlxAnimate)
	var _matrix:FlxMatrix = new FlxMatrix();

	var _refMat:FlxMatrix = null;

	@:allow(flxanimate.FlxAnimate)
	var _color:ColorTransform = new ColorTransform();

	@:allow(flxanimate.FlxAnimate)
	var _scrollF:FlxPoint;

	public var scaleX(default, set):Float = 1;
	public var scaleY(default, set):Float = 1;

	public var rotation:Float = 0;

	/**
	 * Creates a new `FlxElement` instance.
	 * @param name the name of the element. `WARNING:` this name is dynamic, in other words, this name can used for the limb or the symbol!
	 * @param symbol the symbol settings, ignore this if you want to add a limb.
	 * @param matrix the matrix of the element.
	 */
	public function new(?bitmap:String = null, ?symbol:SymbolParameters = null, ?matrix:FlxMatrix = null)
	{
		super();
		this.bitmap = bitmap;
		this.symbol = symbol;
		if (symbol != null)
			symbol._parent = this;
		this.matrix = (matrix == null) ? new FlxMatrix() : matrix;
	}

	override public function toString()
	{
		return '{matrix: $matrix, bitmap: $bitmap}';
	}
	override public function destroy()
	{
		super.destroy();
		_parent = null;
		if (symbol != null) {
			symbol.destroy();
			symbol = null;
		}
		bitmap = null;
		matrix = null;
	}

	public function updateRender(elapsed:Float, curFrame:Int, dictionary:Map<String, FlxSymbol>, ?swfRender:Bool = false)
	{
		update(elapsed);

		if (symbol != null && dictionary.exists(symbol.name))
		{
			var length = dictionary[symbol.name].length;
			var curFF = curFrame + symbol.firstFrame;
			
			curFF = switch (symbol.loop)
			{
				case Loop: curFF % length;
				case PlayOnce: cast FlxMath.bound(curFF, 0, length - 1);
				default: symbol.firstFrame;
			}

			symbol.update(curFF);
			@:privateAccess
			if (symbol._renderDirty && _parent != null && _parent._cacheAsBitmap)
			{
				symbol._renderDirty = false;
				_parent._renderDirty = true;
			}
			dictionary[symbol.name].updateRender(elapsed, curFF, dictionary, swfRender);
		}
	}

	static var matrixNames = ["m00","m01","m10","m11","m30","m31"];

	public static function fromJSON(element:Element)
	{
		var symbol = element.SI != null;
		var params:SymbolParameters = null;
		if (symbol)
		{
			params = new SymbolParameters();
			params.instance = element.SI.IN;
			params.type = switch (element.SI.ST)
			{
				case movieclip, "movieclip": MovieClip;
				case button, "button": Button;
				default: Graphic;
			}

			var _bl = params.instance.indexOf("_bl");
			if (_bl != -1)
			{
				_bl += 3;

				var end = params.instance.indexOf("_", _bl);
				params.blendMode = cast Std.parseInt(params.instance.substring(_bl, end));

				params.instance = params.instance.substring(end + 1);
			}
			var lp:LoopType = (element.SI.LP == null) ? loop : element.SI.LP.split("R")[0];
			params.loop = switch (lp) // remove the reverse sufix
			{
				case playonce, "playonce": PlayOnce;
				case singleframe, "singleframe": SingleFrame;
				default: Loop;
			}
			params.reverse = (element.SI.LP == null) ? false : StringTools.contains(element.SI.LP, "R");
			params.firstFrame = element.SI.FF ?? 0;
			params.colorEffect = AnimationData.fromColorJson(element.SI.C);
			params.name = element.SI.SN;
			params.transformationPoint = FlxPoint.weak(element.SI.TRP.x, element.SI.TRP.y);
			params.filters = AnimationData.fromFilterJson(element.SI.F);
		}

		var m3d = (symbol) ? element.SI.M3D : element.ASI.M3D;
		var m:Array<Float> = [];

		if (m3d == null)
		{
			// Initialize with identity matrix if m3d is null
			m = [1, 0, 0, 1, 0, 0];
		}
		else if (Std.isOfType(m3d, Array))
		{
			m = [m3d[0], m3d[1], m3d[4], m3d[5], m3d[12], m3d[13]];
		}
		else
		{
			// Assuming m3d is an object with properties m00, m01, m02, etc.
			m = [for(field in matrixNames) Reflect.field(m3d, field)];
		}

		var pos = symbol ? element.SI.bitmap.POS : element.ASI.POS;
		if (pos == null)
			pos = {x: 0, y: 0};
		return new FlxElement((symbol) ? element.SI.bitmap.N : element.ASI.N, params, new FlxMatrix(m[0], m[1], m[2], m[3], m[4] + pos.x, m[5] + pos.y));
	}

	public static function fromJSONEx(element:Element)
	{
		var symbol = element.SI != null;
		var params:SymbolParameters = null;
		if (symbol)
		{
			params = new SymbolParameters();
			params.instance = element.SI.IN;
			params.type = switch (element.SI.ST)
			{
				case movieclip, "movieclip": MovieClip;
				case button, "button": Button;
				default: Graphic;
			}

			params.blendMode = element.SI.B;

			var lp:LoopType = (element.SI.LP == null) ? loop : element.SI.LP.split("R")[0];
			params.loop = switch (lp) // remove the reverse sufix
			{
				case playonce, "playonce": PlayOnce;
				case singleframe, "singleframe": SingleFrame;
				default: Loop;
			}
			params.reverse = (element.SI.LP == null) ? false : StringTools.contains(element.SI.LP, "R");
			params.firstFrame = element.SI.FF ?? 0;
			params.colorEffect = AnimationData.fromColorJson(element.SI.C);
			params.name = element.SI.SN;
			params.transformationPoint = FlxPoint.weak(element.SI.TRP.x, element.SI.TRP.y);
			params.filters = AnimationData.fromFilterJsonEx(element.SI.F);
		}

		var m = [];
		if (symbol && element.SI.MX != null || element.ASI.MX != null)
		{
			var mx = (symbol) ? element.SI.MX : element.ASI.MX;
			m[0] = mx[0];
			m[1] = mx[1];
			m[4] = mx[2];
			m[5] = mx[3];
			m[12] = mx[4];
			m[13] = mx[5];
		}
		else if (symbol && element.SI.M3D != null || element.ASI.M3D != null)
		{
			var m3d = (symbol) ? element.SI.M3D : element.ASI.M3D;
			//var array = Reflect.fields(m3d);
			m = m3d;
		}

		return new FlxElement((symbol) ? element.SI.bitmap.N : element.ASI.N, params, new FlxMatrix(m[0], m[1], m[4], m[5], m[12], m[13]));
	}

	function set_bitmap(value:String)
	{
		if (value != bitmap && symbol != null && symbol.cacheAsBitmap)
			symbol._renderDirty = true;

		return bitmap = value;
	}
	function set_matrix(value:FlxMatrix)
	{
		(value == null) ? matrix.identity() : matrix = value;

		return value;
	}

	/*
	private function __setTransform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float):Void
	{
		var transform = matrix;
		if (transform.a == a && transform.b == b && transform.c == c && transform.d == d && transform.tx == tx && transform.ty == ty)
		{
			return;
		}

		var scaleX = 0.0;
		var scaleY = 0.0;

		if (b == 0)
		{
			scaleX = a;
		}
		else
		{
			scaleX = Math.sqrt(a * a + b * b);
		}

		if (c == 0)
		{
			scaleY = d;
		}
		else
		{
			scaleY = Math.sqrt(c * c + d * d);
		}

		@:bypassAccessor
		this.scaleX = scaleX;
		@:bypassAccessor
		this.scaleY = scaleY;

		var rotation = (180 / Math.PI) * Math.atan2(d, c) - 90;

		this.rotation = rotation;
	}
	*/

	function set_scaleX(value:Float)
	{
		if (scaleX == value) return value;

		matrix.a = value;
		_refMat.a = value;

		return scaleX = value;
	}
	function set_scaleY(value:Float)
	{
		if (scaleX == value) return value;

		matrix.a = value;
		_refMat.a = value;

		return scaleX = value;
	}
}