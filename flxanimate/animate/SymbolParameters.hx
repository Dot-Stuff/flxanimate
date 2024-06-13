package flxanimate.animate;

import flixel.math.FlxRect;
import flixel.FlxCamera;
import openfl.geom.Rectangle;
import flxanimate.interfaces.IFilterable;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import haxe.extern.EitherType;
import flixel.math.FlxMatrix;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.FlxGraphic;
import openfl.filters.BitmapFilter;
import flixel.math.FlxPoint;
import openfl.geom.ColorTransform;
import flxanimate.data.AnimationData;
import flxanimate.effects.FlxColorEffect;
import flixel.FlxG;

/**
 * `SymbolParameters` defines and separates from what a `FlxElement` considered as a `Shape` and a `FlxElement` considered as a `Symbol`.
 *
 * It adds metadata information on the symbol's behaviour, such as:
 * - `Type`, this can be considered as:
 *      - Type of `Symbol`.
 *      - Type of `Looping`.
 * - `Effects`, such as:
 *      - `Color Effects`.
 *      - `Filters`.
 * - Symbol `Animation` behaviour.
 */
class SymbolParameters implements IFilterable
{
	@:allow(flxanimate.FlxAnimate)
	var _filterCamera:FlxCamera;

	@:allow(flxanimate.animate.FlxElement)
	var _parent:FlxElement;

	@:allow(flxanimate.FlxAnimate)
	var _filterFrame:FlxFrame;

	@:allow(flxanimate.FlxAnimate)
	var _bmp1:BitmapData;

	@:allow(flxanimate.FlxAnimate)
	var _bmp2:BitmapData;

	@:allow(flxanimate.FlxAnimate)
	var _filterMatrix:FlxMatrix;

	/**
	 * The `FlxElement`'s own name identifier. **WARNING:** do NOT confuse with `name`!
	 */
	public var instance:String;

	/**
	 * The type of the symbol, this may vary in three categories:
	 * - Graphic
	 * - MovieClip
	 * - Button.
	 * @see [Types of Symbols](https://helpx.adobe.com/animate/how-to/types-of-symbols.html)
	 */
	public var type(default, set):SymbolT;
	/**
	 * The type of loop that the symbol is been set to.
	 * There are three types (excluding the reversed options):
	 * - Loop
	 * - Play Once
	 * - Single Frame.
	 * **WARNING:** if `type` is **NOT** set to `Graphic`, this option will not let you modify it.
	 */
	public var loop(default, set):Loop;
	/**
	 * Whether the looping animation is reversed or not.
	 * It is ignored when `loop` is set to `SingleFrame`.
	 */
	public var reverse:Bool;
	/**
	 * An `Int` that references the frame of the referenced symbol.
	 */
	public var firstFrame(default, set):Int =  0;

	@:allow(flxanimate.animate.FlxKeyFrame)
	@:allow(flxanimate.animate.FlxElement)
	@:allow(flxanimate.FlxAnimate)
	/**
	 * Internal, checks the current frame it's at at the moment to force a filter render.
	 */
	var _curFrame:Int = 0;
	/**
	 * The referenced symbol's name. **WARNING:** do NOT confuse with `instance`!
	 */
	public var name:String;

	public var colorEffect(default, set):FlxColorEffect;

	public var blendMode(default, set):BlendMode = NORMAL;

	public var cacheAsBitmap(get, set):Bool;

	var _cacheAsBitmap:Bool = false;

	@:allow(flxanimate.animate.FlxElement)
	@:allow(flxanimate.FlxAnimate)
	@:allow(flxanimate.animate.FlxKeyFrame)
	var _renderDirty:Bool = false;

	@:allow(flxanimate.animate.FlxKeyFrame)

	@:allow(flxanimate.FlxAnimate)
	@:allow(flxanimate.animate.FlxAnim)
	var _colorEffect(get, null):ColorTransform;

	public var transformationPoint:FlxPoint;

	public var filters(default, set):Array<BitmapFilter>;

	public var cacheAsBitmapMatrix:FlxMatrix;

	var _needSecondBmp:Bool = false;


	/**
	 * Creates a new `SymbolParameters` instance.
	 * @param name The name referencing an existing symbol.
	 * @param instance The name of this instance.
	 * @param type The Type of Symbol it will behave like.
	 * @param loop The type of looping it will use. **WARNING:** This can be ignored if `type` isn't set to `Graphic`!
	 *
	 */
	public function new(?name:String = null, ?instance:String = "", ?type:SymbolT = Graphic, ?loop:Loop = Loop)
	{
		this.name = name;
		this.instance = instance;
		this.type = type;
		this.loop = loop;
		firstFrame = 0;
		transformationPoint = new FlxPoint();
		colorEffect = None;
		_curFrame = 0;
		filters = null;
		cacheAsBitmapMatrix = new FlxMatrix();
		_filterMatrix = new FlxMatrix();
	}

	public function destroy()
	{
		instance = null;
		type = null;
		reverse = false;
		firstFrame = 0;
		name = null;
		colorEffect = null;
		transformationPoint = null;

		if (_filterFrame != null)
			FlxG.bitmap.remove(_filterFrame.parent);

		_filterFrame = FlxDestroyUtil.destroy(_filterFrame);
		_filterCamera = FlxDestroyUtil.destroy(_filterCamera);
		_filterMatrix = null;
		FlxG.bitmap.remove(FlxG.bitmap.get(FlxG.bitmap.findKeyForBitmap(_bmp1)));
		_bmp1 = FlxDestroyUtil.dispose(_bmp1);
		FlxG.bitmap.remove(FlxG.bitmap.get(FlxG.bitmap.findKeyForBitmap(_bmp2)));
		_bmp2 = FlxDestroyUtil.dispose(_bmp2);
	}

	function set_type(type:SymbolT)
	{
		this.type = type;
		loop = (type == null) ? null : Loop;

		if (type == Graphic)
		{
			filters = null;
			blendMode = NORMAL;
			FlxDestroyUtil.destroy(_filterFrame);
			cacheAsBitmap = false;
		}

		return type;
	}

	@:allow(flxanimate.animate.FlxKeyFrame)
	@:allow(flxanimate.animate.FlxElement)
	function update(frame:Int)
	{
		if (_curFrame != frame)
		{
			_renderDirty = true;
			_curFrame = frame;
		}

		@:privateAccess
		if (colorEffect != null && colorEffect.renderDirty)
			colorEffect.process();

		if (filters == null || filters.length == 0 || _renderDirty) return;

			@:privateAccess
		for (filter in filters)
		{
			if (filter.__renderDirty)
				_renderDirty = true;
		}
	}

	function set_loop(loop:Loop)
	{
		if (type == null) return this.loop = null;
		this.loop = switch (type)
		{
			case MovieClip: Loop;
			case Button: SingleFrame;
			default: loop;
		}

		return loop;
	}

	function set_firstFrame(value:Int)
	{
		if (type == Graphic && firstFrame != value)
		{
			firstFrame = value;
			_renderDirty = true;
		}

		return value;
	}

	public function reset()
	{
		name = null;
		type = Graphic;
		loop = Loop;
		instance = "";
		firstFrame = 0;
		transformationPoint.set();
		colorEffect = None;
	}

	function get__colorEffect()
	{
		return null;
	}

	function set_colorEffect(value:EitherType<ColorEffect, FlxColorEffect>)
	{
		if (cacheAsBitmap)
			_renderDirty = true;

		if (value == null)
			value = None;

		if ((value is ColorEffect))
		{
			colorEffect = AnimationData.parseColorEffect(value);
		}
		else
			colorEffect = value;

		return colorEffect;
	}

	function set_filters(filters:Array<BitmapFilter>)
	{
		if (type == Graphic) return null;

		if (filters == this.filters) return filters;

		_needSecondBmp = false;
		if (filters != null && filters.length > 0)
		{
			_renderDirty = true;

			@:privateAccess
			for (filter in filters)
			{
				if (filter.__preserveObject)
					_needSecondBmp = true;
			}
		}
		else
		{
			if (_cacheAsBitmap)
				_renderDirty = true;
			else if (_filterFrame != null)
			{
				FlxG.bitmap.remove(_filterFrame.parent);
				_filterFrame = FlxDestroyUtil.destroy(_filterFrame);
				FlxG.bitmap.remove(FlxG.bitmap.get(FlxG.bitmap.findKeyForBitmap(_bmp1)));
				_bmp1 = FlxDestroyUtil.dispose(_bmp1);
				FlxG.bitmap.remove(FlxG.bitmap.get(FlxG.bitmap.findKeyForBitmap(_bmp2)));
				_bmp2 = FlxDestroyUtil.dispose(_bmp2);
			}
		}

		return this.filters = filters;
	}

	function set_blendMode(value:BlendMode)
	{
		if (value == null)
			value = NORMAL;

		if (type == Graphic) return blendMode = NORMAL;

		if (blendMode != value)
		{
			blendMode = value;
			if (blendMode != NORMAL && _filterFrame == null)
				_renderDirty = true;
		}
		return value;
	}

	function get_cacheAsBitmap()
	{
		if (type == Graphic) return false;


		if (filters != null && filters.length > 0 || blendMode != NORMAL) return true;

		return _cacheAsBitmap;
	}
	@:allow(flxanimate.FlxAnimate)
	function updateBitmaps(rect:Rectangle)
	{
		if (_filterFrame == null || (rect.width > _filterFrame.parent.bitmap.width || rect.height > _filterFrame.parent.bitmap.height))
		{
			var wid = (_filterFrame == null || rect.width > _filterFrame.parent.width) ? rect.width * 1.25 : _filterFrame.parent.width;
			var hei = (_filterFrame == null || rect.height > _filterFrame.parent.height) ? rect.height * 1.25 : _filterFrame.parent.height;
			if (_filterFrame != null)
			{
				_filterFrame.parent.destroy();
				FlxG.bitmap.remove(FlxG.bitmap.get(FlxG.bitmap.findKeyForBitmap(_bmp1)));
				if (_needSecondBmp)
					FlxG.bitmap.remove(FlxG.bitmap.get(FlxG.bitmap.findKeyForBitmap(_bmp2)));
			}
			else
			{
				@:privateAccess
				_filterFrame = new FlxFrame(null);
			}

			_filterFrame.parent = FlxG.bitmap.add(new BitmapData(Math.ceil(wid), Math.ceil(hei),0));
			_bmp1 = new BitmapData(Math.ceil(wid), Math.ceil(hei), 0);
			FlxGraphic.fromBitmapData(_bmp1);
			if (_needSecondBmp)
			{
				_bmp2 = new BitmapData(Math.ceil(wid), Math.ceil(hei), 0);
				FlxGraphic.fromBitmapData(_bmp2);
			}

			_filterFrame.frame = new FlxRect(0, 0, wid, hei);
			_filterFrame.sourceSize.set(rect.width, rect.height);
			@:privateAccess
			_filterFrame.cacheFrameMatrix();
		}
		else
		{
			_bmp1.fillRect(_bmp1.rect, 0);
			_filterFrame.parent.bitmap.fillRect(_filterFrame.parent.bitmap.rect, 0);
			if (_needSecondBmp)
				_bmp2.fillRect(_bmp2.rect, 0);
			else if (_bmp2 != null)
			{
				FlxG.bitmap.remove(FlxG.bitmap.get(FlxG.bitmap.findKeyForBitmap(_bmp2)));
				_bmp2 = null;
			}

		}

		_needSecondBmp = false;
	}
	function set_cacheAsBitmap(value:Bool)
	{
		if (type == Graphic) return false;

		if (value) _renderDirty = true;

		return _cacheAsBitmap = value;
	}
}