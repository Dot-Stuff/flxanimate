package flxanimate.filters;

#if !flash
import openfl.filters.BitmapFilterType;
import openfl.filters.DropShadowFilter;
import openfl.filters.BitmapFilterShader;
import openfl.filters.GlowFilter;
import openfl.display.DisplayObjectRenderer;
import openfl.display.Shader;
import openfl.utils.ByteArray;
import openfl.display.BitmapData;
import openfl.filters.BitmapFilter;

/**
	The `GradientBevelFilter` class lets you apply a gradient bevel effect to
	display objects. A gradient bevel is a beveled edge, enhanced with gradient
	color, on the outside, inside, or top of an object. Beveled edges make objects
	look three-dimensional. You can apply the filter to any display object
	(that is, objects that inherit from the `DisplayObject` class), such as `MovieClip`,
	`SimpleButton`, `TextField`, and `Video` objects, as well as to `BitmapData` objects.

	The use of filters depends on the object to which you apply the filter:

	- To apply filters to display objects, use the filters property. Setting the
	  filters property of an object does not modify the object, and you can remove
	  the filter by clearing the filters property.

	- To apply filters to `BitmapData` objects, use the `BitmapData.applyFilter()`
	  method. Calling `applyFilter()` on a BitmapData object takes the source `BitmapData`
	  object and the filter object and generates a filtered image as a result.

	If you apply a filter to a display object, the `cacheAsBitmap` property
	of the display object is set to true. If you clear all filters, the original
	value of `cacheAsBitmap` is restored.

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
	limitation is 2,880 pixels in height and 2,880 pixels in width. For
	example, if you zoom in on a large movie clip with a filter applied, the
	filter is turned off if the resulting image exceeds the maximum
	dimensions.
*/
@:access(openfl.filters.GlowFilter)
@:access(flxanimate.filters.GradientGlowFilter)
@:access(openfl.filters.DropShadowFilter)
class GradientBevelFilter extends BitmapFilter
{
	@:noCompletion private static var __colorRatioShader = new ColorRatioBevelShader();

	/**
		An array of alpha transparency values for the corresponding colors in the colors array.
		Valid values for each element in the array are `0` to `1.` For example, `.25` sets the alpha
		transparency value to `25%`.

		The alphas property cannot be changed by directly modifying its values. Instead, you
		must get a reference to alphas, make the change to the reference, and then set alphas
		to the reference.

		The `colors`, `alphas`, and `ratios` properties are related. The first element in the colors
		array corresponds to the first element in the alphas array and in the ratios array,
		and so on.
	 */
	public var alphas(get, set):Array<Float>;

	/**
		The angle, in degrees. Valid values are `0` to `360`. The default is `45`.

		The `angle` value represents the angle of the theoretical light source falling on the
		object and determines the placement of the effect relative to the object. If distance is
		set to `0`, the effect is not offset from the object, and therefore the `angle` property
		has no effect.
	 */
	public var angle(get, set):Float;

	/**
		The amount of horizontal blur. Valid values are `0` to `255`. A blur of 1 or less means
		that the original image is copied as is. The default value is `4`. Values that are a power of 2
		(such as 2, 4, 8, 16, and 32) are optimized to render more quickly than other values.
	 */
	public var blurX(get, set):Float;

	/**
		The amount of vertical blur. Valid values are `0` to `255`. A blur of 1 or less means
		that the original image is copied as is. The default value is `4`. Values that are a power of 2
		(such as 2, 4, 8, 16, and 32) are optimized to render more quickly than other values.
	 */
	public var blurY(get, set):Float;

	/**
		An array of RGB hexadecimal color values to use in the gradient. For example, red is `0xFF0000`,
		blue is `0x0000FF`, and so on.

		The `colors` property cannot be changed by directly modifying its values. Instead, you must
		get a reference to colors, make the change to the reference, and then set colors to the
		reference.

		The `colors`, `alphas`, and `ratios` properties are related. The first element in the colors
		array corresponds to the first element in the alphas array and in the ratios array,
		and so on.
	 */
	public var colors(get, set):Array<Int>;

	/**
		The offset distance of the glow. The default value is `4`.
	 */
	public var distance(get, set):Float;

	/**
		Specifies whether the object has a knockout effect. A knockout effect makes the object's fill
		transparent and reveals the background color of the document. The value `true` specifies a knockout
		effect; the default value is `false` (no knockout effect).
	 */
	public var knockout(get, set):Bool;

	/**
		The number of times to apply the filter. The default value is `BitmapFilterQuality.LOW`, which is
		equivalent to applying the filter once. The value `BitmapFilterQuality.MEDIUM` applies the filter
		twice; the value `BitmapFilterQuality.HIGH` applies it three times. Filters with lower values are
		rendered more quickly.

		For most applications, a quality value of low, medium, or high is sufficient. Although you can
		use additional numeric values up to `15` to achieve different effects, higher values are rendered
		more slowly. Instead of increasing the value of quality, you can often get a similar effect,
		and with faster rendering, by simply increasing the values of the `blurX` and `blurY` properties.
	 */
	public var quality(get, set):Int;

	/**
		An array of color distribution ratios for the corresponding colors in the colors array. Valid
		values are `0` to `255`.

		The ratios property cannot be changed by directly modifying its values. Instead, you must get
		a reference to ratios, make the change to the reference, and then set ratios to the reference.

		The `colors`, `alphas`, and `ratios` properties are related. The first element in the colors
		array corresponds to the first element in the alphas array and in the ratios array,
		and so on.

		Think of the gradient glow filter as a glow that emanates from the center of the object
		(if the distance value is set to `0`), with gradients that are stripes of color blending into each
		other. The first color in the `colors` array is the outermost color of the glow. The last color is
		the innermost color of the glow.

		Each value in the ratios array sets the position of the color on the radius of the gradient, where
		`0` represents the outermost point of the gradient and `255` represents the innermost point of the
		gradient. The ratio values can range from `0` to `255` pixels, in increasing value; for example
		`[0, 64, 128, 200, 255]`. Values from `0` to `128` appear on the outer edges of the glow. Values
		from `129` to `255` appear in the inner area of the glow. Depending on the ratio values of the
		colors and the type value of the filter, the filter colors might be obscured by the object to which
		the filter is applied.

		In the following code and image, a filter is applied to a black circle movie clip, with the type set
		to `"full"`. For instructional purposes, the first color in the colors array, pink, has an `alpha`
		value of `1`, so it shows against the white document background.
		(In practice, you probably would not want the first color showing in this way.) The last color in the
		array, yellow, obscures the black circle to which the filter is applied:

			var colors:Array = [0xFFCCFF, 0x0000FF, 0x9900FF, 0xFF0000, 0xFFFF00];
			var alphas:Array = [1, 1, 1, 1, 1];
			var ratios:Array = [0, 32, 64, 128, 225];
			var myGGF:GradientGlowFilter = new GradientGlowFilter(0, 0, colors, alphas, ratios, 50, 50, 1, 2, "full", false);

		![diagram](https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/images/gradientGlowDiagram.jpg)

		To achieve a seamless effect with your document background when you set the `type` value to `"outer"`
		or `"full"`, set the first color in the array to the same color as the document background, or set the
		alpha value of the first color to 0; either technique makes the filter blend in with the background.

		If you make two small changes in the code, the effect of the glow can be very different, even with the
		same ratios and colors arrays. Set the alpha value of the first color in the array to `0`, to make the
		filter blend in with the document's white background; and set the type property to `"outer"` or `"inner"`.
		Observe the results, as shown in the following images.

		![OuterGlow](https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/images/gradientGlowOuter.jpg) ![InnerGlow](https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/images/gradientGlowInner.jpg)

		Keep in mind that the spread of the colors in the gradient varies based on the values of the `blurX`, `blurY`,
		`strength`, and `quality` properties, as well as the `ratios` values.
	 */
	public var ratios(get, set):Array<Int>;

	/**
		The strength of the imprint or spread. The higher the value, the more color is imprinted and the stronger
		the contrast between the glow and the background. Valid values are `0` to `255`. A value of `0` means that the
		filter is not applied. The default value is `1`.
	 */
	public var strength(get, set):Float;

	/**
		The placement of the filter effect. Possible values are `openfl.filters.BitmapFilterType` constants:

		- `BitmapFilterType.OUTER` — Glow on the outer edge of the object
		- `BitmapFilterType.INNER` — Glow on the inner edge of the object; the default.
		- `BitmapFilterType.FULL` — Glow on top of the object
	 */
	public var type(get, set):String;


	@:noCompletion private var __alphas:Array<Float>;
	@:noCompletion private var __angle:Float;
	@:noCompletion private var __blurX:Float;
	@:noCompletion private var __horizontalPasses:Int;
	@:noCompletion private var __blurY:Float;
	@:noCompletion private var __verticalPasses:Int;
	@:noCompletion private var __colors:Array<Int>;
	@:noCompletion private var __distance:Float;
	@:noCompletion private var __knockout:Bool;
	@:noCompletion private var __quality:Int;
	@:noCompletion private var __ratios:Array<Int>;
	@:noCompletion private var __strength:Float;
	@:noCompletion private var __type:String;
	@:noCompletion private var __offsetX:Float;
	@:noCompletion private var __offsetY:Float;

	@:noCompletion private var __colorFadeArr:ByteArray;


	/**
		Initializes the filter with the specified parameters.


		@param distance The offset distance of the glow.

		@param angle The angle, in degrees. Valid values are `0` to `360`.

		@param colors An array of RGB hexadecimal color values to use in the gradient. For example, red is `0xFF0000`, blue is
					  `0x0000FF`, and so on.

		@param alphas An array of alpha transparency values for the corresponding colors in the colors array. Valid values for each
					  element in the array are `0` to `1`. For example, a value of `.25` sets the alpha transparency value to `25%`.

		@param ratios An array of color distribution ratios. Valid values are `0` to `255`. This value defines the percentage of the
					  width where the color is sampled at `100` percent.

		@param blurX The amount of horizontal blur. Valid values are `0` to `255`. A blur of `1` or less means that the original image
					 is copied as is. Values that are a power of 2 (such as 2, 4, 8, 16 and 32) are optimized to render more quickly
					 than other values.


		@param blurY The amount of vertical blur. Valid values are `0` to `255`. A blur of `1` or less means that the original image
					 is copied as is. Values that are a power of 2 (such as 2, 4, 8, 16 and 32) are optimized to render more quickly
					 than other values.

		@param strength The strength of the imprint or spread. The higher the value, the more color is imprinted and the stronger the
						contrast between the glow and the background. Valid values are `0` to `255`. The larger the value, the stronger
						the imprint. A value of `0` means the filter is not applied.

		@param quality The number of times to apply the filter. Use the `BitmapFilterQuality` constants:

						- `BitmapFilterQuality.LOW`
						- `BitmapFilterQuality.MEDIUM`
						- `BitmapFilterQuality.HIGH`

						For more information, see the description of the quality property.

		@param type The placement of the filter effect. Possible values are the `openfl.filters.BitmapFilterType` constants:

					- `BitmapFilterType.OUTER` — Glow on the outer edge of the object
					- `BitmapFilterType.INNER` — Glow on the inner edge of the object; the default.
					- `BitmapFilterType.FULL` — Glow on top of the object

		@param knockout Specifies whether the object has a knockout effect. A knockout effect makes the object's fill transparent and reveals
						the background color of the document. The value `true` specifies a knockout effect; the default is `false`
						(no knockout effect).
	*/
	public function new(distance:Float = 4, angle:Float = 45, colors:Array<Int> = null, alphas:Array<Float> = null, ratios:Array<Int> = null, blurX:Float = 4,
		blurY:Float = 4, strength:Float = 1, quality:Int = 1, type:String = "inner", knockout:Bool = false)
	{
		super();

		__offsetX = 0;
		__offsetY = 0;

		__angle = angle;
		__distance = distance;
		__angle = angle;
		__colors = colors;
		__alphas = alphas;
		__ratios = ratios;
		__blurX = blurX;
		__blurY = blurY;
		__strength = strength;
		__quality = quality;
		__type = type;
		__knockout = knockout;
		__colorFadeArr = new ByteArray();

		__updateSize();
		__setColorBitmap();

		__needSecondBitmapData = true;
		__preserveObject = true;
		__renderDirty = true;
	}

	/**
		Returns a copy of this filter object.

		@return `BitmapFilter` — A new `GradientBevelFilter` instance with all the same properties as the original `GradientBevelFilter` instance.
	 */
	public override function clone():BitmapFilter
	{
		return new GradientGlowFilter(__distance, __angle, __colors, __alphas, __ratios, __blurX, __blurY, __strength, __quality, __type, __knockout);
	}


	@:noCompletion private override function __initShader(renderer:DisplayObjectRenderer, pass:Int, sourceBitmapData:BitmapData):Shader
	{
		var blurPass = pass;
		var numBlurPasses = __horizontalPasses + __verticalPasses;

		if (blurPass < numBlurPasses)
		{
			var shader = GlowFilter.__blurAlphaShader;
			if (blurPass < __horizontalPasses)
			{
				var scale = Math.pow(0.5, blurPass >> 1) * 0.5;
				shader.uRadius.value[0] = blurX * scale;
				shader.uRadius.value[1] = 0;
			}
			else
			{
				var scale = Math.pow(0.5, (blurPass - __horizontalPasses) >> 1) * 0.5;
				shader.uRadius.value[0] = 0;
				shader.uRadius.value[1] = blurY * scale;
			}
			shader.uColor.value = [1, 1, 1, 1];
			shader.uStrength.value[0] = 1.0;

			return shader;
		}

		if (pass == numBlurPasses)
		{
			var shader = __colorRatioShader;
			GradientGlowFilter.__colorFadeBmp.setPixels(GradientGlowFilter.__colorFadeBmp.rect, __colorFadeArr);
			shader.colorGradient.input = GradientGlowFilter.__colorFadeBmp;
			shader.offset.value[0] = __offsetX;
			shader.offset.value[1] = __offsetY;
			shader.uStrength.value[0] = __strength;

			return shader;
		}
		switch (type)
		{
			case "outer":
			{
				if (__knockout)
				{
					var shader = GlowFilter.__combineKnockoutShader;
					shader.sourceBitmap.input = sourceBitmapData;
					shader.offset.value[0] = 0.;
					shader.offset.value[1] = 0.;
					return shader;
				}
				var shader = GlowFilter.__combineShader;
				shader.sourceBitmap.input = sourceBitmapData;
				shader.offset.value[0] = 0.;
				shader.offset.value[1] = 0.;
				return shader;
			}
			case "inner":
			{
				if (__knockout)
				{
					var shader = GlowFilter.__innerCombineKnockoutShader;
					shader.sourceBitmap.input = sourceBitmapData;
					shader.offset.value[0] = 0.;
					shader.offset.value[1] = 0.;
					return shader;
				}
				var shader = GlowFilter.__innerCombineShader;
				shader.sourceBitmap.input = sourceBitmapData;
				shader.offset.value[0] = 0.;
				shader.offset.value[1] = 0.;
				return shader;
			}
			case "full":
			{
				if (__knockout)
				{
					var shader = DropShadowFilter.__hideShader;
					shader.sourceBitmap.input = sourceBitmapData;
					shader.offset.value[0] = 0.;
					shader.offset.value[1] = 0.;
					return shader;
				}

				var shader = GradientGlowFilter.__fullCombineShader;
				shader.sourceBitmap.input = sourceBitmapData;
				shader.offset.value[0] = 0.;
				shader.offset.value[1] = 0.;
				return shader;
			}
		}

		return null;

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
		__numShaderPasses = __horizontalPasses + __verticalPasses + 2;
	}

	@:noCompletion private function __setColorBitmap()
	{
		__colorFadeArr.clear();
		if (__colors.length < 0) return;

		var _rat = 0;

		for (i in 0...255)
		{
			var preRatio = __ratios[_rat];


			var currentRatio = (__ratios.length - 1 < _rat + 1) ? 255 : __ratios[_rat + 1];

			if (currentRatio < i)
			{
				_rat++;
				preRatio = __ratios[_rat];
				currentRatio = (__ratios.length - 1 < _rat + 1) ? 255 : __ratios[_rat + 1];
			}
			var preAlpha = (__alphas.length - 1 > _rat) ? __alphas[_rat] : 1.;
			var postAlpha = (__alphas.length - 1 > _rat + 1) ? __alphas[_rat + 1] : 1.;

			var preColor = __colors[_rat];

			var postColor = (__colors.length - 1 < _rat + 1) ? preColor : __colors[_rat + 1];

			if (_rat == 0 && preRatio > i)
			{
				__colorFadeArr.writeInt(Std.int(preAlpha * 255) | preColor);
				continue;
			}
			var preA = (Std.int(preAlpha * 255)) & 0xFF;
			var preR = (preColor >> 16) & 0xFF;
			var preG = (preColor >> 8) & 0xFF;
			var preB = preColor & 0xFF;

			var postA = (Std.int(postAlpha * 255)) & 0xFF;
			var postR = (postColor >> 16) & 0xFF;
			var postG = (postColor >> 8) & 0xFF;
			var postB = postColor & 0xFF;

			var progr = (i - preRatio) / (currentRatio - preRatio);
			var q = 1 - progr;

			__colorFadeArr.writeInt(Std.int(preA * q + postA * progr) << 24 | Std.int(preR * q + postR * progr) << 16 | Std.int(preG * q + postG * progr) << 8 | Std.int(preB * q + postB * progr));
		}

		__colorFadeArr.position = 0;
	}

	@:noCompletion private function get_alphas()
	{
		return __alphas;
	}

	@:noCompletion private function set_alphas(value:Array<Float>)
	{
		if (value != __alphas)
		{
			__alphas = value;
			__renderDirty = true;
			__setColorBitmap();
		}
		return value;
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

	@:noCompletion private function get_colors()
	{
		return __colors;
	}

	@:noCompletion private function set_colors(value:Array<Int>)
	{
		if (value != __colors)
		{
			__colors = value;
			__renderDirty = true;
			__setColorBitmap();
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

	@:noCompletion private function get_ratios()
	{
		return __ratios;
	}

	@:noCompletion private function set_ratios(value:Array<Int>)
	{
		if (value != __ratios)
		{
			__ratios = value;
			__renderDirty = true;
			__setColorBitmap();
		}
		return value;
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
private class ColorRatioBevelShader extends BitmapFilterShader
{
	@:glFragmentSource("
		uniform sampler2D openfl_Texture;
		uniform vec2 openfl_TextureSize;

		uniform sampler2D colorGradient;
		uniform float uStrength;
		varying vec4 textureCoords;

		void main(void)
		{
			float HA = texture2D(openfl_Texture, textureCoords.zw).a * uStrength;
			float SA = texture2D(openfl_Texture, textureCoords.xy).a * uStrength;

			float a = SA;


			SA -= HA;
			HA -= a;

			SA = clamp(SA, 0., 1.);
			HA = clamp(HA, 0., 1.);

			float hf = (128. / 255.);
			vec4 bevel = (texture(colorGradient, vec2((1. - SA) * hf, 0.)) + texture(colorGradient, vec2(hf + HA * hf, 0.)));

			gl_FragColor = bevel;
		}
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
		uStrength.value = [0];
		offset.value = [0, 0];
		#end
	}
}
// #else
// typedef GradientBevelFilter = flash.filters.GradientBevelFilter;
#end