package flxanimate.data;

import openfl.display.BlendMode;
import flxanimate.effects.*;
import flxanimate.motion.AdjustColor;
import flixel.util.FlxDirection;
import flixel.util.FlxColor;
import openfl.geom.ColorTransform;
import openfl.filters.*;


@:noCompletion
class AnimationData
{
	// public static var internalParam:EReg = ~/_FA{/;

	// public static var bracketReg:EReg = ~/(\{([^{}]|(?R))*\})/s;.

	/**
	 * Checks a value, using `Reflection`.
	 * @param abstracto The abstract in specific.
	 * @param things The fields you want to use.
	 * @return The value in specific casted as `Dynamic`.
	 */
	public static function getFieldBool(abstracto:Dynamic, things:Array<String>):Dynamic
	{
		//TODO: The comment below this comment.
		// GeoKureli told me that Reflect is shit, but I have literally no option but to use this.
		// If I have another thing to use that works the same, should replace this lol
		if (abstracto == null)
			return null;
		for (thing in things)
		{
			if (Reflect.hasField(abstracto, thing))
			{
				return Reflect.field(abstracto, thing);
			}
		}
		return null;
	}

	/**
	 * Checks a value, using `Reflection`.
	 * @param abstracto The abstract in specific.
	 * @param things The fields you want to use.
	 * @param set What value you want to set.
	 * @return The value in specific casted as `Dynamic`.
	 */
	public static function setFieldBool(abstracto:Dynamic, things:Array<String>, set:Dynamic):Dynamic
	{
		//TODO: The comment below this comment.
		// GeoKureli told me that Reflect is shit, but I have literally no option but to use this.
		// If I have another thing to use that works the same, should replace this lol
		if (abstracto == null)
			return null;
		for (thing in things)
		{
			if (Reflect.hasField(abstracto, thing))
			{
				Reflect.setField(abstracto, thing, set);
				return set;
			}
		}
		if(things.length == 0)
			return null;
		Reflect.setField(abstracto, things[0], set);
		return set;
	}
	/**
	 * Parses a Color Effect from a JSON file into a enumeration of `ColorEffect`.
	 * @param effect The json field.
	 */
	public static function fromColorJson(effect:ColorEffects = null)
	{
		var colorEffect = None;


		if (effect == null) return colorEffect;

		switch (effect.M)
		{
			case Tint, "Tint":
				colorEffect = Tint(colorFromString(effect.TC), effect.TM);
			case Alpha, "Alpha":
				colorEffect = Alpha(effect.AM);
			case Brightness, "Brightness":
				colorEffect = Brightness(effect.BRT);
			case Advanced, "Advanced":
			{
				var CT = new ColorTransform();
				CT.redMultiplier = effect.RM;
				CT.redOffset = effect.RO;
				CT.greenMultiplier = effect.GM;
				CT.greenOffset = effect.GO;
				CT.blueMultiplier = effect.BM;
				CT.blueOffset = effect.BO;
				CT.alphaMultiplier = effect.AM;
				CT.alphaOffset = effect.AO;
				colorEffect = Advanced(CT);
			}
			default:
				flixel.FlxG.log.error('color Effect mode "${effect.M}" is invalid or not supported!');
		}
		return colorEffect;
	}
	static function colorFromString(color:String)
	{
		return Std.parseInt( "0x" + color.substring(1));
	}

	/**
	 * Parses a filter from a JSON file into a `BitmapFilter`
	 * @param filters The JSON field.
	 */
	public static function fromFilterJson(filters:Filters = null)
	{
		if (filters == null) return null;

		var bitmapFilter:Array<BitmapFilter> = [];

		for (filter in Reflect.fields(filters))
		{
			bitmapFilter.unshift(filterFromString(filter.split("_")[0], Reflect.field(filters, filter)));
		}

		return bitmapFilter;
	}
	public static function fromFilterJsonEx(filters:Array<Dynamic> = null)
	{
		if (filters == null) return null;

		var bitmapFilter:Array<BitmapFilter> = [];

		for (filter in filters)
		{
			bitmapFilter.unshift(filterFromString(MacroAnimationData.getFieldBool(filter, ["N", "name"]), filter));
		}

		return bitmapFilter;
	}

	static function filterFromString(field:String, value:Dynamic):BitmapFilter
	{
		switch (field)
		{
			case "DSF", "DropShadowFilter":
			{
				var drop:DropShadowFilter = value;
				return new openfl.filters.DropShadowFilter(drop.DST, drop.AL, colorFromString(drop.C), drop.A, drop.BLX, drop.BLY, drop.STR, drop.Q, drop.IN, drop.KK);
			}
			case "GF", "GlowFilter":
			{
				var glow:GlowFilter = value;
				return new openfl.filters.GlowFilter(colorFromString(glow.C), glow.A, glow.BLX, glow.BLY, glow.STR, glow.Q, glow.IN, glow.KK);
			}
			case "BF", "BevelFilter": // Friday Night Funkin reference ?!??!?!''1'!'?1'1''?1''
			{
				var bevel:BevelFilter = value;
				return new flxanimate.filters.BevelFilter(bevel.DST, bevel.AL, colorFromString(bevel.HC), bevel.HA, colorFromString(bevel.SC), bevel.SA, bevel.BLX, bevel.BLY, bevel.STR, bevel.Q, bevel.TP, bevel.KK);
			}
			case "BLF", "BlurFilter":
			{
				var blur:BlurFilter = value;
				return new openfl.filters.BlurFilter(blur.BLX, blur.BLY, blur.Q);
			}
			case "ACF", "AdjustColorFilter":
			{
				var adjustColor:AdjustColorFilter = value;

				var colorAdjust = new AdjustColor();

				colorAdjust.hue = adjustColor.H;
				colorAdjust.brightness = adjustColor.BRT;
				colorAdjust.contrast = adjustColor.CT;
				colorAdjust.saturation = adjustColor.SAT;

				return new openfl.filters.ColorMatrixFilter(colorAdjust.calculateFinalFlatArray());
			}

			case "GGF", "GradientGlowFilter":
			{
				var gradient:GradientFilter = value;
				var colors:Array<Int> = [];
				var alphas:Array<Float> = [];
				var ratios:Array<Int> = [];

				for (entry in gradient.GE)
				{
					colors.push(colorFromString(entry.C));
					alphas.push(entry.A);
					ratios.push(Std.int(entry.R * 255));
				}


				return new flxanimate.filters.GradientGlowFilter(gradient.DST, gradient.AL, colors, alphas, ratios, gradient.BLX, gradient.BLY, gradient.STR, gradient.Q, gradient.TP, gradient.KK);
			}
			case "GBF", "GradientBevelFilter":
			{
				var gradient:GradientFilter = value;
				var colors:Array<Int> = [];
				var alphas:Array<Float> = [];
				var ratios:Array<Int> = [];

				for (entry in gradient.GE)
				{
					colors.push(colorFromString(entry.C));
					alphas.push(entry.A);
					ratios.push(Math.round(entry.R * 255));
				}


				return new flxanimate.filters.GradientBevelFilter(gradient.DST, gradient.AL, colors, alphas, ratios, gradient.BLX, gradient.BLY, gradient.STR, gradient.Q, gradient.TP, gradient.KK);
			}
		}

		return null;
	}
	/**
	 * Transforms a `ColorEffect` into a `ColorTransform`.
	 * @param colorEffect The `ColorEffect`.
	 */
	public static function parseColorEffect(colorEffect:ColorEffect = None)
	{
		var CT = null;

		//if ([None, null].indexOf(colorEffect) == -1)
		if(colorEffect != None && colorEffect != null)
		{
			var params = colorEffect.getParameters();
			CT = switch (colorEffect.getName())
			{
				case "Tint": new FlxTint(params[0], params[1]);
				case "Alpha": new FlxAlpha(params[0]);
				case "Brightness": new FlxBrightness(params[0]);
				case "Advanced": new FlxAdvanced(params[0]);
				default: new FlxColorEffect();
			}
		}


		return CT;
	}
}
/**
 * The types of Color Effects the symbol can have.
 */
enum ColorEffect
{
	None;
	Brightness(Bright:Float);
	Tint(Color:flixel.util.FlxColor, Opacity:Float);
	Alpha(Alpha:Float);
	Advanced(transform:ColorTransform);
}
/**
 * The looping method for the current symbol.
 */
enum Loop
{
	Loop;
	PlayOnce;
	SingleFrame;
}
/**
 * The type the symbol can be.
 */
enum SymbolT
{
	Graphic;
	MovieClip;
	Button;
}
/**
 * The type of behaviour `FlxLayer` can become.
 */
enum LayerType
{
	Normal;
	Clipper;
	Clipped(layer:String);
	Folder;
}

/**
 * The main structure of a basic Animation file in the texture atlas.
 */
abstract AnimAtlas({}) from {}
{
	/**
	 * The main thing, the animation that makes the different drawings animate together and shit
	 */
	public var AN(get, never):Animation;
	/**
	 * This is where all the symbols that the main animation uses are stored. Can be `null`!
	 */
	public var SD(get, never):SymbolDictionary;
	/**
	 * A metadata, consisting of the framerate the document had been exported.
	 */
	public var MD(get, never):MetaData;


	function get_AN():Animation
	{
		return MacroAnimationData.getFieldBool(this, ["AN", "ANIMATION"]);
	}


	function get_MD():MetaData
	{
		return MacroAnimationData.getFieldBool(this, ["MD", "metadata"]);
	}
	function get_SD()
	{
		return MacroAnimationData.getFieldBool(this, ["SD", "SYMBOL_DICTIONARY"]);
	}
}
/**
 * An `Array` of multiple symbols. All symbols in the Dictionary are supposedly used in the main Animation or in other symbols.
 */
abstract SymbolDictionary({}) from {}
{
	/**
	 * The list of symbols.
	 */
	public var S(get, never):Array<SymbolData>;


	function get_S():Array<SymbolData>
	{
		return MacroAnimationData.getFieldBool(this, ["S", "Symbols"]);
	}
}
@:forward
/**
 *
 */
abstract Animation(SymbolData) from {}
{
	/**
	 * The name of the Flash document the texture atlas was exported with.
	 */
	public var N(get, never):String;
	/**
	 * The Stage Instance. This represents the element settings the texture atlas was exported when clicking on-stage
	 * **WARNING:** if you export the texture atlas inside the symbol dictionary, this field won't appear, meaning it can be `null`.
	 */
	public var STI(get, never):StageInstance;

	function get_N():String
	{
		return MacroAnimationData.getFieldBool(this, ["N", "name"]);
	}
	function get_STI()
	{
		return MacroAnimationData.getFieldBool(this, ["STI", "StageInstance"]);
	}
}
/**
 * The main position how the symbol you exported was set, Acting almost identically as an `Element`, with the exception of not having an Atlas Sprite to call (not that I'm aware of).
 * **WARNING:** This may depend on how you exported your texture atlas, Meaning that this can be `null`
 */
abstract StageInstance({})
{
	/**
	 * The instance of the Element flagged as a `Symbol`.
	 * **WARNING:** This can be `null`!
	 */
	public var SI(get, never):SymbolInstance;


	function get_SI():SymbolInstance
	{
		return MacroAnimationData.getFieldBool(this, ["SI", "SYMBOL_Instance"]);
	}
}
/**
 * A small Symbol specifier, consisting of the name of the Symbol and its timeline.
 */
abstract SymbolData({}) from {}
{
	/**
	 * The name of the symbol.
	 */
	public var SN(get, never):String;
	/**
	 * The timeline of the Symbol.
	 */
	public var TL(get, never):Timeline;

	function get_SN():String
	{
		return MacroAnimationData.getFieldBool(this, ["SN", "SYMBOL_name"]);
	}
	function get_TL():Timeline
	{
		return MacroAnimationData.getFieldBool(this, ["TL", "TIMELINE"]);
	}
}
/**
 * The main timeline of the symbol.
 */
abstract Timeline({}) from {}
{
	/**
	 * An `Array` that goes in a inverted order, from the bottom to the top.
	 */
	public var L(get, never):Array<Layers>;


	function get_L():Array<Layers>
	{
		return MacroAnimationData.getFieldBool(this, ["L", "LAYERS"]);
	}
}
/**
 * A layer instance inside the `Timeline`.
 */
abstract Layers({}) from {}
{
	/**
	 * The name of the layer.
	 */
	public var LN(get, never):String;
	/**
	 * Type of layer, It's usually to indicate that the Layer is a mask or is masked.
	 */
	public var LT(get, never):String;
	/**
	 * if the layer is masked, this field will appear to explain which layer is being clipped to, usually the next one.
	 */
	public var Clpb(get, never):String;
	/**
	 * An `Array` of KeyFrames inside the layer.
	 */
	public var FR(get, never):Array<Frame>;


	function get_LN():String
	{
		return MacroAnimationData.getFieldBool(this, ["LN", "Layer_name"]);
	}
	function get_LT():String
	{
		return MacroAnimationData.getFieldBool(this, ["LT", "Layer_type"]);
	}
	function get_Clpb():String
	{
		return MacroAnimationData.getFieldBool(this, ["Clpb", "Clipped_by"]);
	}
	function get_FR():Array<Frame>
	{
		return MacroAnimationData.getFieldBool(this, ["FR", "Frames"]);
	}
}
/**
 * The metadata, consisting of a single variable to indicate the framerate the texture atlas was exported with.
 */
abstract MetaData({}) from {}
{

	/**
	 * The framerate.
	 */
	public var FRT(get, never):Float;
	
	/**
	 * the current version of the exporter (Used in BetterTA)
	 */
	public var V(get, never):String;

	function get_FRT()
	{
		return MacroAnimationData.getFieldBool(this, ["FRT", "framerate"]);
	}
	function get_V()
	{
		return MacroAnimationData.getFieldBool(this, ["V", "version"]);
	}
}
/**
 * A KeyFrame with everything essential + labels and ColorEffects/Filters.
 */
abstract Frame({}) from {}
{
	/**
	 * The "name of the frame", basically labels that you can use as thingies for more cool stuff to program lol
	 */
	public var N(get, never):String;
	/**
	 * The frame index, aka the current number frame.
	 */
	public var I(get, never):Int;
	/**
	 * The duration of the frame.
	 */
	public var DU(get, never):Int;
	/**
	 * The elements that the frame has. Drawings/symbols to be specific
	 */
	public var E(get, never):Array<Element>;


	/**
	 * The Color Effect of the symbol, it says color but it affects alpha too lol.
	 */
	public var C(get, never):ColorEffects;


	/**
	 * Filter stuff, this is the reason why you can't add custom shaders, srry
	 */
	public var F(get, never):OneOfTwo<Array<Dynamic>, Filters>;


	function get_N():String
	{
		return MacroAnimationData.getFieldBool(this, ["N", "name"]);
	}
	function get_I():Int
	{
		return MacroAnimationData.getFieldBool(this, ["I", "index"]);
	}
	function get_DU():Int
	{
		return MacroAnimationData.getFieldBool(this, ["DU", "duration"]);
	}
	function get_E():Array<Element>
	{
		return MacroAnimationData.getFieldBool(this, ["E", "elements"]);
	}
	function get_C()
	{
		return MacroAnimationData.getFieldBool(this, ["C", "color"]);
	}


	function get_F()
	{
		return MacroAnimationData.getFieldBool(this, ["F", "filters"]);
	}
}
/**
 * The Element thing inside the frame
 */
@:forward
abstract Element(StageInstance)
{
	/*
	 * the Sprite of the animation, aka the non Symbol.
	 */
	public var ASI(get, never):AtlasSymbolInstance;


	function get_ASI():AtlasSymbolInstance
	{
		return MacroAnimationData.getFieldBool(this, ["ASI", "ATLAS_SPRITE_instance"]);
	}
}
/**
 * The Symbol Abstract
 */
abstract SymbolInstance({}) from {}
{
	/**
	 * the name of the symbol.
	 */
	public var SN(get, never):String;


	/**
	 * the name instance of the Symbol.
	 */
	public var IN(get, never):String;
	/**
	 * the type of symbol,
	 * Which can be a:
	 * - Graphic
	 * - MovieClip
	 * - Button
	 */
	public var ST(get, never):SymbolType;


	/**
	 * bitmap Settings, Used in 2018 and 2019
	 */
	public var bitmap(get, never):Bitmap;

	public var B(get, never):BlendMode;

	/**
	 * this sets on which frame it's the symbol, Graphic only
	 */
	public var FF(get, never):Int;
	/**
	 * the Loop Type of the symbol, which can be:
	 * - Loop
	 * - Play Once
	 * - Single Frame
	 */
	public var LP(get, never):LoopType;
	/**
	 * the Transformation Point of the symbol, basically the pivot that determines how it scales or not in Flash
	 */
	public var TRP(get, never):TransformationPoint;
	/**
	 * The Matrix of the Symbol, Be aware of Neo! He can be anywhere!!! :fearful:
	 */
	public var M3D(get, never):OneOfTwo<Array<Float>, Matrix3D>;

	/**
	 * a 2D version of the matrix. (used only in BetterTA)
	 */
	public var MX(get, never):Array<Float>;
	
	/**
	 * The Color Effect of the symbol, it says color but it affects alpha too lol.
	 */
	public var C(get, never):ColorEffects;


	/**
	 * Filter stuff, this is the reason why you can't add custom shaders, srry
	 */
	public var F(get, never):OneOfTwo<Array<Dynamic>, Filters>;


	function get_SN()
	{
		return MacroAnimationData.getFieldBool(this, ["SN", "SYMBOL_name"]);
	}


	function get_IN()
	{
		return MacroAnimationData.getFieldBool(this, ["IN", "Instance_Name"]);
	}


	function get_ST()
	{
		return MacroAnimationData.getFieldBool(this, ["ST", "symbolType"]);
	}


	function get_bitmap()
	{
		return MacroAnimationData.getFieldBool(this, ["BM", "bitmap"]);
	}

	function get_B()
	{
		return MacroAnimationData.getFieldBool(this, ["B", "blend"]);
	}

	function get_FF()
	{
		var ff:Null<Int> = MacroAnimationData.getFieldBool(this, ["FF", "firstFrame"]);
		return (ff == null) ? 0 : ff;
	}


	function get_LP()
	{
		return MacroAnimationData.getFieldBool(this, ["LP", "loop"]);
	}


	function get_TRP()
	{
		return MacroAnimationData.getFieldBool(this, ["TRP", "transformationPoint"]);
	}


	function get_M3D()
	{
		return MacroAnimationData.getFieldBool(this, ["M3D", "Matrix3D"]);
	}

	function get_MX()
	{
		return MacroAnimationData.getFieldBool(this, ["MX", "Matrix"]);
	}

	function get_C()
	{
		return MacroAnimationData.getFieldBool(this, ["C", "color"]);
	}


	function get_F()
	{
		return MacroAnimationData.getFieldBool(this, ["F", "filters"]);
	}
}
abstract ColorEffects({}) from {}
{
	/**
	 * What type of Effect is it.
	 */
	public var M(get, never):ColorMode;
	/**
	 * tint Color, basically, How's the color gonna be lol.
	 */
	public var TC(get, never):String;
	/**
	 * tint multiplier, or the alpha of **THE COLOR!** Don't forget that.
	 */
	public var TM(get, never):Float;


	public var AM(get, never):Float;
	public var AO(get, never):Int;


	// Red Multiplier and Offset
	public var RM(get, never):Float;
	public var RO(get, never):Int;
	// Green Multiplier and Offset
	public var GM(get, never):Float;
	public var GO(get, never):Int;
	// Blue Multiplier and Offset
	public var BM(get, never):Float;
	public var BO(get, never):Int;


	public var BRT(get, never):Float;


	function get_M()
	{
		return MacroAnimationData.getFieldBool(this, ["M", "mode"]);
	}
	function get_TC()
	{
		return MacroAnimationData.getFieldBool(this, ["TC", "tintColor"]);
	}
	function get_TM()
	{
		return MacroAnimationData.getFieldBool(this, ["TM", "tintMultiplier"]);
	}
	function get_AM()
	{
		return MacroAnimationData.getFieldBool(this, ["AM", "alphaMultiplier"]);
	}
	function get_AO()
	{
		return MacroAnimationData.getFieldBool(this, ["AO", "AlphaOffset"]);
	}
	function get_RM()
	{
		return MacroAnimationData.getFieldBool(this, ["RM", "RedMultiplier"]);
	}
	function get_RO()
	{
		return MacroAnimationData.getFieldBool(this, ["RO", "redOffset"]);
	}
	function get_GM()
	{
		return MacroAnimationData.getFieldBool(this, ["GM", "greenMultiplier"]);
	}
	function get_GO()
	{
		return MacroAnimationData.getFieldBool(this, ["GO", "greenOffset"]);
	}
	function get_BM()
	{
		return MacroAnimationData.getFieldBool(this, ["BM", "blueMultiplier"]);
	}
	function get_BO()
	{
		return MacroAnimationData.getFieldBool(this, ["BO", "blueOffset"]);
	}
	function get_BRT()
	{
		return MacroAnimationData.getFieldBool(this, ["BRT", "Brightness"]);
	}
}
abstract Filters({})
{
	/**
	 * Adjust Color filter is a workaround to give some color adjustment, including hue-rotation, saturation, brightness and contrast.
	 * After calculating every required adjustment, it gets the matrix and then the filter is applied as a `ColorMatrixFilter`.
	 * @see flxanimate.motion.AdjustColor
	 * @see flxanimate.motion.ColorMatrix
	 * @see flxanimate.motion.DynamicMatrix
	 * @see openfl.filters.ColorMatrixFilter
	 */
	public var ACF(get, never):AdjustColorFilter;

	public var GF(get, never):GlowFilter;

	function get_ACF()
	{
		return MacroAnimationData.getFieldBool(this, ["ACF", "AdjustColorFilter"]);
	}
	function get_GF()
	{
		return MacroAnimationData.getFieldBool(this, ["GF"]);
	}
}
/**
 * A full matrix calculation thing that seems to behave like a special HSV adjust.
 */
abstract AdjustColorFilter({})
{
	/**
	 * The brightness value. Can be from -100 to 100
	 */
	public var BRT(get, never):Float;
	/**
	 * The value of contrast. Can be from -100 to 100
	 */
	public var CT(get, never):Float;
	/**
	 * The value of saturation. Can be from -100 to 100
	 */
	public var SAT(get, never):Float;
	/**
	 * The hue value. Can be from -180 to 180
	 */
	public var H(get, never):Float;


	function get_BRT()
	{
		return MacroAnimationData.getFieldBool(this, ["BRT", "brightness"]);
	}
	function get_CT()
	{
		return MacroAnimationData.getFieldBool(this, ["CT", "contrast"]);
	}
	function get_SAT()
	{
		return MacroAnimationData.getFieldBool(this, ["SAT", "saturation"]);
	}
	function get_H()
	{
		return MacroAnimationData.getFieldBool(this, ["H", "hue"]);
	}
}
/**
 * This blur filter gives instructions of how the blur should be applied onto the symbol/frame.
 */
abstract BlurFilter({})
{
	/**
	 * The amount of blur horizontally.
	 */
	public var BLX(get, never):Float;
	/**
	 * The amount of blur vertically.
	 */
	public var BLY(get, never):Float;
	/**
	 * The number of passes the filter has.
	 * When the quality is set to three, it should approximate to a Gaussian Blur.
	 * Obviously you can go beyond three, but it'll take more time to render.
	 */
	public var Q(get, never):Int;

	function get_BLX()
	{
		return MacroAnimationData.getFieldBool(this, ["BLX", "blurX"]);
	}
	function get_BLY()
	{
		return MacroAnimationData.getFieldBool(this, ["BLY", "blurY"]);
	}
	function get_Q()
	{
		return MacroAnimationData.getFieldBool(this, ["Q", "quality"]);
	}
}

@:forward
abstract GlowFilter(BlurFilter)
{
	public var C(get, never):String;
	public var A(get, never):Float;
	public var STR(get, never):Float;
	public var KK(get, never):Bool;
	public var IN(get, never):Bool;

	function get_C()
	{
		return MacroAnimationData.getFieldBool(this, ["C", "color"]);
	}
	function get_A()
	{
		return MacroAnimationData.getFieldBool(this, ["A", "alpha"]);
	}
	function get_STR()
	{
		return MacroAnimationData.getFieldBool(this, ["STR", "strength"]);
	}
	function get_KK()
	{
		return MacroAnimationData.getFieldBool(this, ["KK", "knockout"]);
	}
	function get_IN()
	{
		return MacroAnimationData.getFieldBool(this, ["IN", "inner"]);
	}
}

@:forward
abstract DropShadowFilter(GlowFilter)
{
	public var HO(get, never):Bool;
	public var AL(get, never):Float;
	public var DST(get, never):Float;

	function get_HO()
	{
		return MacroAnimationData.getFieldBool(this, ["HO", "hideObject"]);
	}
	function get_AL()
	{
		return MacroAnimationData.getFieldBool(this, ["AL", "angle"]);
	}
	function get_DST()
	{
		return MacroAnimationData.getFieldBool(this, ["DST", "distance"]);
	}
}

@:forward
abstract BevelFilter(BlurFilter)
{
	public var SC(get, never):String;
	public var SA(get, never):Float;
	public var HC(get, never):String;
	public var HA(get, never):Float;
	public var STR(get, never):Float;
	public var KK(get, never):Bool;
	public var AL(get, never):Float;
	public var DST(get, never):Float;
	public var TP(get, never):String;

	function get_SC()
	{
		return MacroAnimationData.getFieldBool(this, ["SC", "shadowColor"]);
	}
	function get_SA()
	{
		return MacroAnimationData.getFieldBool(this, ["SA", "shadowAlpha"]);
	}
	function get_HC()
	{
		return MacroAnimationData.getFieldBool(this, ["HC", "highlightColor"]);
	}
	function get_HA()
	{
		return MacroAnimationData.getFieldBool(this, ["HA", "highlightAlpha"]);
	}
	function get_STR()
	{
		return MacroAnimationData.getFieldBool(this, ["STR", "strength"]);
	}
	function get_KK()
	{
		return MacroAnimationData.getFieldBool(this, ["KK", "knockout"]);
	}
	function get_AL()
	{
		return MacroAnimationData.getFieldBool(this, ["AL", "angle"]);
	}
	function get_DST()
	{
		return MacroAnimationData.getFieldBool(this, ["DST", "distance"]);
	}
	function get_TP()
	{
		return MacroAnimationData.getFieldBool(this, ["TP", "type"]);
	}
}
@:forward
abstract GradientFilter(BlurFilter)
{
	public var STR(get, never):Float;
	public var KK(get, never):Bool;
	public var AL(get, never):Float;
	public var DST(get, never):Float;
	public var TP(get, never):String;
	public var GE(get, never):Array<GradientEntry>;


	function get_STR()
	{
		return MacroAnimationData.getFieldBool(this, ["STR", "strength"]);
	}
	function get_KK()
	{
		return MacroAnimationData.getFieldBool(this, ["KK", "knockout"]);
	}
	function get_AL()
	{
		return MacroAnimationData.getFieldBool(this, ["AL", "angle"]);
	}
	function get_DST()
	{
		return MacroAnimationData.getFieldBool(this, ["DST", "distance"]);
	}
	function get_TP()
	{
		return MacroAnimationData.getFieldBool(this, ["TP", "type"]);
	}
	function get_GE()
	{
		return MacroAnimationData.getFieldBool(this, ["GE", "GradientEntries"]);
	}
}

abstract GradientEntry({})
{
	public var R(get, never):Float;
	public var C(get, never):String;
	public var A(get, never):Float;


	function get_R()
	{
		return MacroAnimationData.getFieldBool(this, ["R", "ratio"]);
	}
	function get_C()
	{
		return MacroAnimationData.getFieldBool(this, ["C", "color"]);
	}
	function get_A()
	{
		return MacroAnimationData.getFieldBool(this, ["A", "alpha"]);
	}

}

enum abstract ColorMode(String) from String to String
{
	var Tint = "T";
	var Advanced = "AD";
	var Alpha = "CA";
	var Brightness = "CBRT";
}
abstract Bitmap({}) from {}
{
	/**
	 * The name of the drawing, basically determines which one of the sprites on spritemap should be used.
	 */
	public var N(get, never):String;


	/**
	 * Only used in earliest versions of texture atlas release. checks the position, nothing else lol
	 */
	public var POS(get, never):TransformationPoint;
	function get_N()
	{
		return MacroAnimationData.getFieldBool(this, ["N", "name"]);
	}
	function get_POS()
	{
		return MacroAnimationData.getFieldBool(this, ["POS", "Position"]);
	}
}
/**
 * The Sprite/Drawing abstract
 */
@:forward
abstract AtlasSymbolInstance(Bitmap) from {}
{
	/**
	 * The matrix of the sprite itself. Can be either an array or a typedef.
	 */
	public var M3D(get, never):OneOfTwo<Array<Float>, Matrix3D>;

	/**
	 * a 2D version of the matrix. (used only in BetterTA)
	 */
	public var MX(get, never):Array<Float>;

	function get_M3D()
	{
		return MacroAnimationData.getFieldBool(this, ["M3D", "Matrix3D"]);
	}

	function get_MX()
	{
		return MacroAnimationData.getFieldBool(this, ["MX", "Matrix"]);
	}
}

typedef Matrix3D =
{
	var m00:Float;
	var m01:Float;
	var m02:Float;
	var m03:Float;
	var m10:Float;
	var m11:Float;
	var m12:Float;
	var m13:Float;
	var m20:Float;
	var m21:Float;
	var m22:Float;
	var m23:Float;
	var m30:Float;
	var m31:Float;
	var m32:Float;
	var m33:Float;
}
/**
 * Position Stuff
 */
typedef TransformationPoint =
{
	var x:Float;
	var y:Float;
}


@:forward
enum abstract LoopType(String) from String to String
{
	var loop = "LP";
	var playonce = "PO";
	var singleframe = "SF";
}


enum abstract SymbolType(String) from String to String
{
	var graphic = "G";
	var movieclip = "MC";
	var button = "B";
}
@:forward
abstract OneOfTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}
