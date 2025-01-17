package flxanimate.filters;

import openfl.filters.GlowFilter;
import openfl.filters.BitmapFilterType;
import openfl.filters.BitmapFilter;
import openfl.filters.BitmapFilterShader;
import openfl.display.Shader;
import openfl.display.DisplayObjectRenderer;
import openfl.display.BitmapData;

/**
	The BevelFilter class lets you add a bevel effect to display objects.
	A bevel effect gives objects such as buttons a three-dimensional look.
	You can customize the look of the bevel with different highlight and
	shadow colors, the amount of blur on the bevel, the angle of the bevel,
	the placement of the bevel, and a knockout effect. You can apply the
	filter to any display object (that is, objects that inherit from the
	DisplayObject class), such as MovieClip, SimpleButton, TextField,
	and Video objects, as well as to BitmapData objects.

	To create a new filter, use the constructor `new BevelFilter()`.
	The use of filters depends on the object to which you apply the filter:

	* To apply filters to display objects use the `filters`
	property(inherited from DisplayObject). Setting the `filters`
	property of an object does not modify the object, and you can remove the
	filter by clearing the `filters` property.
	* To apply filters to BitmapData objects, use the
	`BitmapData.applyFilter()` method. Calling
	`applyFilter()` on a BitmapData object takes the source
	BitmapData object and the filter object and generates a filtered image as a
	result.

	If you apply a filter to a display object, the value of the
	`cacheAsBitmap` property of the display object is set to
	`true`. If you clear all filters, the original value of
	`cacheAsBitmap` is restored.

	This filter supports Stage scaling. However, it does not support general
	scaling, rotation, and skewing. If the object itself is scaled(if
	`scaleX` and `scaleY` are set to a value other than
	1.0), the filter is not scaled. It is scaled only when the user zooms in on
	the Stage.

	A filter is not applied if the resulting image exceeds the maximum
	dimensions. In AIR 1.5 and Flash Player 10, the maximum is 8,191 pixels in
	width or height, and the total number of pixels cannot exceed 16,777,215
	pixels.(So, if an image is 8,191 pixels wide, it can only be 2,048 pixels
	high.) In Flash Player 9 and earlier and AIR 1.1 and earlier, the
	limitation is 2,880 pixels in height and 2,880 pixels in width. If, for
	example, you zoom in on a large movie clip with a filter applied, the
	filter is turned off if the resulting image exceeds the maximum
	dimensions.
*/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.filters.BitmapFilterType)
@:access(openfl.filters.GlowFilter)
class BevelFilter extends BitmapFilter
{
	@:noCompletion private static var __fullCombineShader = new FullCombineShader();
	@:noCompletion private static var __innerCombineShader = new InnerCombineShader();
	@:noCompletion private static var __combineShader = new CombineShader();

	/**
		The angle of the bevel. Valid values are from 0 to 360°.
		The default value is 45°.

		The angle value represents the angle of the theoretical
		light source falling on the object and determines
		the placement of the effect relative to the object.
		If the distance property is set to 0, the effect is not
		offset from the object and, therefore,
		the angle property has no effect.
	**/
	public var angle(get, set):Float;

	/**
		The amount of horizontal blur, in pixels. Valid values are from 0 to 255 (floating point).
		The default value is 4. Values that are a power of 2 (such as 2, 4, 8, 16, and 32)
		are optimized to render more quickly than other values.
	**/
	public var blurX(get, set):Float;

	/**
		The amount of vertical blur, in pixels. Valid values are from 0 to 255 (floating point).
		The default value is 4. Values that are a power of 2 (such as 2, 4, 8, 16, and 32)
		are optimized to render more quickly than other values.
	**/
	public var blurY(get, set):Float;

	/**
		The offset distance for the bevel, in pixels. The default value is 4.0
		(floating point).
	**/
	public var distance(get, set):Float;

	/**
		The alpha transparency value of the highlight color.
		The value is specified as a normalized value from 0 to 1. For example, .25 sets a transparency value of 25%.
		The default value is 1.
	**/
	public var highlightAlpha(get, set):Float;

	/**
		The highlight color of the bevel. Valid values are in hexadecimal format, 0xRRGGBB. The default is 0xFFFFFF.
	**/
	public var highlightColor(get, set):Int;

	/**
		Applies a knockout effect(`true`), which effectively makes the
		object's fill transparent and reveals the background color of the
		document. The default is `false`(no knockout).
	**/
	public var knockout(get, set):Bool;

	/**
		The number of times to apply the filter. The default value is
		`BitmapFilterQuality.LOW`, which is equivalent to applying the
		filter once. The value `BitmapFilterQuality.MEDIUM` applies the
		filter twice; the value `BitmapFilterQuality.HIGH` applies it
		three times. Filters with lower values are rendered more quickly.

		For most applications, a quality value of low, medium, or high is
		sufficient. Although you can use additional numeric values up to 15 to
		achieve different effects, higher values are rendered more slowly. Instead
		of increasing the value of `quality`, you can often get a
		similar effect, and with faster rendering, by simply increasing the values
		of the `blurX` and `blurY` properties.
	**/
	public var quality(get, set):Int;

	/**
		The alpha transparency value of the shadow color.
		The value is specified as a normalized value from 0 to 1. For example, .25 sets a transparency value of 25%.
		The default value is 1.
	**/
	public var shadowAlpha(get, set):Float;

	/**
		The shadow color of the bevel. Valid values are in hexadecimal format, 0xRRGGBB. The default is 0xFFFFFF.
	**/
	public var shadowColor(get, set):Int;

	/**
		The strength of the imprint or spread. The higher the value, the more
		color is imprinted and the stronger the contrast between the shadow and
		the background. Valid values are from 0 to 255.0. The default is 1.0.
	**/
	public var strength(get, set):Float;

	/**
		The placement of the bevel on the object. Inner and outer bevels are placed on the inner or outer edge; a full bevel is placed on the entire object. Valid values are the BitmapFilterType constants:

			- `BitmapFilterType.INNER`
			- `BitmapFilterType.OUTER`
			- `BitmapFilterType.FULL`
	**/
	public var type(get, set):String;

	@:noCompletion private var __angle:Float;
	@:noCompletion private var __blurX:Float;
	@:noCompletion private var __blurY:Float;
	@:noCompletion private var __distance:Float;
	@:noCompletion private var __highlightAlpha:Float;
	@:noCompletion private var __highlightColor:Int;
	@:noCompletion private var __knockout:Bool;
	@:noCompletion private var __quality:Int;
	@:noCompletion private var __shadowAlpha:Float;
	@:noCompletion private var __shadowColor:Int;
	@:noCompletion private var __strength:Float;
	@:noCompletion private var __type:String;
	@:noCompletion private var __horizontalPasses:Int;
	@:noCompletion private var __offsetX:Float;
	@:noCompletion private var __offsetY:Float;
	@:noCompletion private var __verticalPasses:Int;

	#if openfljs
	@:noCompletion private static function __init__()
	{
		untyped Object.defineProperties(DropShadowFilter.prototype, {
			"angle": {
				get: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function () { return this.get_angle (); }"),
				set: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function (v) { return this.set_angle (v); }")
			},
			"blurX": {
				get: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function () { return this.get_blurX (); }"),
				set: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function (v) { return this.set_blurX (v); }")
			},
			"blurY": {
				get: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function () { return this.get_blurY (); }"),
				set: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function (v) { return this.set_blurY (v); }")
			},
			"distance": {
				get: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function () { return this.get_distance (); }"),
				set: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function (v) { return this.set_distance (v); }")
			},
			"highlightAlpha": {
				get: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function () { return this.get_highlightAlpha (); }"),
				set: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function (v) { return this.set_highlightAlpha (v); }")
			},
			"highlightColor": {
				get: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function () { return this.get_highlightColor (); }"),
				set: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function (v) { return this.set_highlightColor (v); }")
			},
			"knockout": {
				get: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function () { return this.get_knockout (); }"),
				set: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function (v) { return this.set_knockout (v); }")
			},
			"quality": {
				get: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function () { return this.get_quality (); }"),
				set: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function (v) { return this.set_quality (v); }")
			},
			"shadowAlpha": {
				get: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function () { return this.get_shadowAlpha (); }"),
				set: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function (v) { return this.set_shadowAlpha (v); }")
			},
			"shadowColor": {
				get: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function () { return this.get_shadowColor (); }"),
				set: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function (v) { return this.set_shadowColor (v); }")
			},
			"strength": {
				get: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function () { return this.get_strength (); }"),
				set: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function (v) { return this.set_strength (v); }")
			},
			"type": {
				get: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function () { return this.get_type (); }"),
				set: untyped #if haxe4 js.Syntax.code #else __js__ #end ("function (v) { return this.set_type (v); }")
			},
		});
	}
	#end

	/**
		Initializes a new BevelFilter instance with the specified parameters.

		@param distance The offset distance of the bevel, in pixels (floating point).

		@param angle The angle of the bevel, from 0 to 360 degrees.

		@param highlightColor The highlight color of the bevel, 0xRRGGBB.

		@param highlightAlpha The alpha transparency value of the highlight color.
							  Valid values are 0.0 to 1.0. For example,
							  .25 sets a transparency value of 25%.

		@param shadowColor The shadow color of the bevel, 0xRRGGBB.

		@param shadowAlpha The alpha transparency value of the shadow color. Valid
						   values are 0.0 to 1.0. For example,
						   .25 sets a transparency value of 25%.

		@param blurX The amount of horizontal blur in pixels. Valid values are 0 to 255.0
					 (floating point).

		@param blurY The amount of vertical blur in pixels. Valid values are 0 to 255.0
					 (floating point).

		@param strength The strength of the imprint or spread. The higher the value,
						the more color is imprinted and the stronger the contrast
						between the bevel and the background. Valid values are 0 to 255.0.

		@param quality The quality of the bevel. Valid values are 0 to 15,
					   but for most applications,
					   you can use `BitmapFilterQuality` constants:

						- `BitmapFilterQuality.LOW`
						- `BitmapFilterQuality.MEDIUM`
						- `BitmapFilterQuality.HIGH`

						Filters with lower values render faster. You can use the other
						available numeric values to achieve different effects.

		@param type The type of bevel. Valid values are `BitmapFilterType` constants:
					`BitmapFilterType.INNER`, `BitmapFilterType.OUTER`,
					or `BitmapFilterType.FULL`.

		@param knockout Applies a knockout effect (`true`),
						which effectively makes the object's fill transparent and
						reveals the background color of the document.

		@see `BitmapFilterQuality`
		@see `BitmapFilterType`
	 */
	public function new(distance:Float = 4, angle:Float = 45, highlightColor:Int = 0xFFFFFF, highlightAlpha:Float = 1, shadowColor:Int = 0x000000, shadowAlpha:Float = 1, blurX:Float = 4, blurY:Float = 4, strength:Float = 1, quality:Int = 1, type:String = "inner", knockout:Bool = false)
	{
		super();

		__offsetX = 0;
		__offsetY = 0;

		__distance = distance;
		__angle = angle;
		__highlightColor = highlightColor;
		__highlightAlpha = highlightAlpha;
		__shadowColor = shadowColor;
		__shadowAlpha = shadowAlpha;
		__blurX = blurX;
		__blurY = blurY;
		__strength = strength;
		__quality = quality;
		__type = type;
		__knockout = knockout;

		__updateSize();

		__needSecondBitmapData = true;
		__preserveObject = true;
		__renderDirty = true;
	}
	public override function clone():BitmapFilter
	{
		return new BevelFilter(__distance, __angle, __highlightColor, __highlightAlpha, __shadowColor, __shadowAlpha, __blurX, __blurY, __strength, __quality, __type, __knockout);
	}
	// TODO: Implement __applyFilter


	@:noCompletion private override function __initShader(renderer:DisplayObjectRenderer, pass:Int, sourceBitmapData:BitmapData):Shader
	{
		#if !macro
		if (pass < __horizontalPasses + __verticalPasses)
		{
			var shader = GlowFilter.__blurAlphaShader;
			if (pass < __horizontalPasses)
			{
				var scale = Math.pow(0.5, pass >> 1) * 0.5;
				shader.uRadius.value[0] = blurX * scale;
				shader.uRadius.value[1] = 0;
			}
			else
			{
				var scale = Math.pow(0.5, (pass - __horizontalPasses) >> 1) * 0.5;
				shader.uRadius.value[0] = 0;
				shader.uRadius.value[1] = blurY * scale;
			}
			shader.uColor.value[3] = 1;

			shader.uStrength.value[0] = 1.0;
			return shader;
		}

		var shader:BevelShader = switch(BitmapFilterType.fromString(__type))
		{
			case BitmapFilterType.INNER: __innerCombineShader;
			case BitmapFilterType.OUTER: __combineShader;
			case BitmapFilterType.FULL: __fullCombineShader;
			default: null;
		}

		if (shader != null)
		{
			shader.sourceBitmap.input = sourceBitmapData;
			shader.uColorH.value[0] = ((highlightColor >> 16) & 0xFF) / 255;
			shader.uColorH.value[1] = ((highlightColor >> 8) & 0xFF) / 255;
			shader.uColorH.value[2] = (highlightColor & 0xFF) / 255;
			shader.uColorH.value[3] = highlightAlpha;

			shader.uColorS.value[0] = ((shadowColor >> 16) & 0xFF) / 255;
			shader.uColorS.value[1] = ((shadowColor >> 8) & 0xFF) / 255;
			shader.uColorS.value[2] = (shadowColor & 0xFF) / 255;
			shader.uColorS.value[3] = shadowAlpha;
			shader.uStrength.value[0] = __strength;

			shader.knockout.value[0] = (__knockout) ? 1 : 0;
			shader.offset.value[0] = __offsetX;
			shader.offset.value[1] = __offsetY;
		}

		return shader;
		#else
		return null;
		#end
	}
	@:noCompletion private function __updateSize():Void
	{
		__offsetX = Std.int(__distance * Math.cos(__angle * Math.PI / 180));
		__offsetY = Std.int(__distance * Math.sin(__angle * Math.PI / 180));
		__topExtension = (type != BitmapFilterType.INNER) ? Math.ceil(Math.abs(__offsetY) + __blurY) : 0;
		__bottomExtension =  __topExtension;
		__leftExtension = (type != BitmapFilterType.INNER) ? Math.ceil(Math.abs(__offsetX) + __blurX) : 0;
		__rightExtension = __leftExtension;
		__calculateNumShaderPasses();
	}

	@:noCompletion private function __calculateNumShaderPasses():Void
	{
		__horizontalPasses = (__blurX <= 0) ? 0 : Math.round(__blurX * (__quality / 4)) + 1;
		__verticalPasses = (__blurY <= 0) ? 0 : Math.round(__blurY * (__quality / 4)) + 1;
		__numShaderPasses = __horizontalPasses + __verticalPasses + 1;
	}

	@:noCompletion private function get_angle():Float
	{
		return __angle;
	}

	@:noCompletion private function set_angle(value:Float):Float
	{
		if (value != __angle)
		{
			__angle = value;
			__renderDirty = true;
			__updateSize();
		}
		return value;
	}

	@:noCompletion private function get_blurX():Float
	{
		return __blurX;
	}

	@:noCompletion private function set_blurX(value:Float):Float
	{
		if (value != __blurX)
		{
			__blurX = value;
			__renderDirty = true;
			__updateSize();
		}
		return value;
	}

	@:noCompletion private function get_blurY():Float
	{
		return __blurY;
	}

	@:noCompletion private function set_blurY(value:Float):Float
	{
		if (value != __blurY)
		{
			__blurY = value;
			__renderDirty = true;
			__updateSize();
		}
		return value;
	}

	@:noCompletion private function get_distance():Float
	{
		return __distance;
	}

	@:noCompletion private function set_distance(value:Float):Float
	{
		if (value != __distance)
		{
			__distance = value;
			__renderDirty = true;
			__updateSize();
		}
		return value;
	}

	@:noCompletion private function get_highlightAlpha():Float
	{
		return __highlightAlpha;
	}

	@:noCompletion private function set_highlightAlpha(value:Float):Float
	{
		if (value != __highlightAlpha) __renderDirty = true;
		return __highlightAlpha = value;
	}

	@:noCompletion private function get_highlightColor():Int
	{
		return __highlightColor;
	}

	@:noCompletion private function set_highlightColor(value:Int):Int
	{
		if (value != __highlightColor) __renderDirty = true;
		return __highlightColor = value;
	}

	@:noCompletion private function get_knockout():Bool
	{
		return __knockout;
	}

	@:noCompletion private function set_knockout(value:Bool):Bool
	{
		if (value != __knockout) __renderDirty = true;
		return __knockout = value;
	}

	@:noCompletion private function get_quality():Int
	{
		return __quality;
	}

	@:noCompletion private function set_quality(value:Int):Int
	{
		if (value != __quality) __renderDirty = true;
		return __quality = value;
	}

	@:noCompletion private function get_shadowAlpha():Float
	{
		return __shadowAlpha;
	}

	@:noCompletion private function set_shadowAlpha(value:Float):Float
	{
		if (value != __shadowAlpha) __renderDirty = true;
		return __shadowAlpha = value;
	}

	@:noCompletion private function get_shadowColor():Int
	{
		return __shadowColor;
	}

	@:noCompletion private function set_shadowColor(value:Int):Int
	{
		if (value != __shadowColor) __renderDirty = true;
		return __shadowColor = value;
	}

	@:noCompletion private function get_strength():Float
	{
		return __strength;
	}

	@:noCompletion private function set_strength(value:Float):Float
	{
		if (value != __strength) __renderDirty = true;
		return __strength = value;
	}

	@:noCompletion private function get_type():String
	{
		return __type;
	}

	@:noCompletion private function set_type(value:String):String
	{
		if (value != __type)
		{
			__type = value;
			__renderDirty = true;
			__updateSize();
		}
		return value;
	}
}

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
private class BevelShader extends BitmapFilterShader
{
	@:glFragmentHeader("
		uniform vec4 uColorH;
		uniform vec4 uColorS;
		uniform float uStrength;
		uniform int knockout;
		uniform sampler2D sourceBitmap;
		varying vec4 textureCoords;
	")
	@:glFragmentBody("
		float HA = texture2D(openfl_Texture, textureCoords.zw).a * uStrength;
		float SA = texture2D(openfl_Texture, textureCoords.xy).a * uStrength;

		float a = SA;


		SA -= HA;
		HA -= a;

		SA = clamp(SA, 0., 1.);
		HA = clamp(HA, 0., 1.);


		vec4 bevel = ((uColorS * SA) + (uColorH * HA));

		vec4 src = texture2D(sourceBitmap, openfl_TextureCoordv);
	")
	@:glVertexHeader("
		uniform vec2 offset;
		varying vec4 textureCoords;
	")

	@:glVertexBody("textureCoords = vec4(openfl_TextureCoord - offset / openfl_TextureSize, openfl_TextureCoord + offset / openfl_TextureSize);")
	public function new()
	{
		super();

		#if !macro
		uColorH.value = [0, 0, 0, 0];
		uColorS.value = [0, 0, 0, 0];
		uStrength.value = [0];
		offset.value = [0, 0];
		knockout.value = [0];
		#end
	}
}

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
private class FullCombineShader extends BevelShader
{
	@:glFragmentSource("
		#pragma header

		void main(void) {

			#pragma body

			if (knockout == 0)
				gl_FragColor = src + bevel;
			else
				gl_FragColor = bevel;
		}
	")
	public function new()
	{
		super();
	}
}
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
private class InnerCombineShader extends BevelShader
{
	@:glFragmentSource("
		#pragma header

		void main(void) {

			#pragma body

			if (knockout == 0)
				gl_FragColor = vec4((src.rgb * (1.0 - bevel.a)) + (bevel.rgb * src.a), src.a);
			else
				gl_FragColor = bevel * src.a;
		}
	")
	public function new()
	{
		super();
	}
}

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
private class CombineShader extends BevelShader
{
	@:glFragmentSource("
		#pragma header

		void main(void) {

			#pragma body

			if (knockout == 0)
				gl_FragColor = src + bevel * (1.0 - src.a);
			else
				gl_FragColor = bevel * (1.0 - src.a);
		}
	")
	public function new()
	{
		super();
	}
}


// cheemsnfriends was here lmao