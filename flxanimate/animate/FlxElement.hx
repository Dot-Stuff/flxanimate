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

	@:allow(flxanimate.FlxAnimate)
	var _color:ColorTransform = new ColorTransform();

	@:allow(flxanimate.FlxAnimate)
	var _scrollF:FlxPoint;



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
		if (symbol != null)
			symbol.destroy();
		bitmap = null;
		matrix = null;
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

			if (symbol.type == MovieClip)
				curFF = 0;


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
			if (StringTools.contains(params.instance, "_bl"))
			{
				var _bl = params.instance.indexOf("_bl");

				if (_bl != -1)
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
		var array = Reflect.fields(m3d);
		if (!Std.isOfType(m3d, Array))
			array.sort((a, b) -> Std.parseInt(a.substring(1)) - Std.parseInt(b.substring(1)));
		var m:Array<Float> = (m3d is Array) ? m3d : [for (field in array) Reflect.field(m3d,field)];

		if (!symbol && m3d == null)
		{
			m[0] = m[5] = 1;
			m[1] = m[4] = m[12] = m[13] = 0;
		}

		var pos = (symbol) ? element.SI.bitmap.POS : element.ASI.POS;
		if (pos == null)
			pos = {x: 0, y: 0};
		return new FlxElement((symbol) ? element.SI.bitmap.N : element.ASI.N, params, new FlxMatrix(m[0], m[1], m[4], m[5], m[12] + pos.x, m[13] + pos.y));
	}
}