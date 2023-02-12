package flxanimate.data;


import flixel.util.FlxDirection;
import flixel.util.FlxColor;
import openfl.geom.ColorTransform;
import openfl.filters.*;


@:noCompletion
class AnimationData
{
	@:noCompletion
	public static function setFieldBool(abstracto:Dynamic, things:Array<String>, ?set:Dynamic):Dynamic
	{
		//TODO: The comment below this comment.
		// GeoKureli told me that Reflect is shit, but I have literally no option but to use this.
		// If I have another thing to use that works the same, should replace this lol
		if (abstracto == null)
			return Reflect.field({}, "");
		for (thing in things)
		{
			if (set != null)
			{
				Reflect.setField(abstracto, thing, set);
				return set;
			}
			if (Reflect.hasField(abstracto, thing))
			{
				return Reflect.field(abstracto, thing);
			}
		}
		return Reflect.field(abstracto, "");
	}
	public static function fromColorJson(effect:ColorEffects = null)
	{
		var colorEffect = None;


		if (effect == null) return colorEffect;
		
		switch (effect.M)
		{
			case Tint, "Tint":
				var tc = "0x" + effect.TC.substring(1);
				
				colorEffect = Tint(Std.parseInt(tc), effect.TM);
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
	public static function fromFilterJson(filters:Filters = null) 
	{
		if (filters == null) return null;
		
		var bitmapFilter:Array<BitmapFilter> = [];


		for (filter in Reflect.fields(filters))
		{
			switch (filter)
			{
				case "GF":
				{
					var glow:GlowFilter = Reflect.field(filters, filter);
					bitmapFilter.push(new openfl.filters.GlowFilter(FlxColor.fromString(glow.C), glow.A, glow.BLX, glow.BLY, glow.STR, glow.Q, glow.IN, glow.KK));
				}
				case "BLF":
				{
					var blur:BlurFilter = Reflect.field(filters, filter);
					bitmapFilter.push(new openfl.filters.BlurFilter(blur.BLX, blur.BLY, blur.Q));
				}
			}
		}


		return bitmapFilter;
	}
	public static function parseColorEffect(colorEffect:ColorEffect = None)
	{
		var CT = new ColorTransform();
        
        if ([None, null].indexOf(colorEffect) == -1)
        {
            var params = colorEffect.getParameters();
            switch (colorEffect.getName())
            {
                case "Tint":
                    var color:flixel.util.FlxColor = params[0];
                    var opacity:Float = params[1];
					
                    CT.redMultiplier -= opacity;
                    CT.redOffset = Math.round(color.red * opacity);
                    CT.greenMultiplier -= opacity;
                    CT.greenOffset = Math.round(color.green * opacity);
                    CT.blueMultiplier -= opacity;
                    CT.blueOffset = Math.round(color.blue * opacity);
					
                case "Alpha":
                    CT.alphaMultiplier = params[0];
                case "Brightness":


                    CT.redMultiplier = CT.greenMultiplier = CT.blueMultiplier -= Math.abs(params[0]);
                    if (params[0] >= 0)
                        CT.redOffset = CT.greenOffset = CT.blueOffset = 255 * params[0];
                case "Advanced":
                    CT.concat(params[0]);
            }
        }


		return CT;
	}
}


enum ColorEffect
{
    None;
    Brightness(Bright:Float);
    Tint(Color:flixel.util.FlxColor, Opacity:Float);
    Alpha(Alpha:Float);
    Advanced(transform:ColorTransform);
}
enum Loop
{
	Loop;
	PlayOnce;
	SingleFrame;
}
enum SymbolT
{
	Graphic;
	MovieClip;
	Button;
}


enum LayerType
{
	Normal;
	Clipper;
	Clipped(layer:String);
	Folder;
}


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
	 * Minor stuff, this checks the framerate the anim is and nothing much tbh
	 */
	public var MD(get, never):MetaData;


	function get_AN():Animation
	{
		return AnimationData.setFieldBool(this, ["AN", "ANIMATION"]);
	}


	function get_MD():MetaData
	{
		return AnimationData.setFieldBool(this, ["MD", "metadata"]);
	}
	function get_SD()
	{
		return AnimationData.setFieldBool(this, ["SD", "SYMBOL_DICTIONARY"]);
	}
}
/**
 * The Dictionary itself, where all the symbols are stored.
 */
abstract SymbolDictionary({}) from {}
{
	/**
	 * The list of symbols.
	 */
	public var S(get, never):Array<SymbolData>;


	function get_S():Array<SymbolData>
	{
		return AnimationData.setFieldBool(this, ["S", "Symbols"]);
	}
}
/**
 * The main animation Thing
 */
abstract Animation({}) from {}
{
	/**
	 * The name of the symbol.
	 */
	public var SN(get, never):String;
	/**
	 * The name of the fla document.
	 */
	public var N(get, never):String;
	/**
	 * The timeline of the symbol.
	 */
	public var TL(get, never):Timeline;
	/**
	 * Its the stage instance of the timeline, basically how was the texture atlas set when it was on "the stage" of Adobe Animate.
	 * Can be included or not depending if you export the atlas on stage or on the symbol dictionary.
	 */
	public var STI(get, never):StageInstance;


	function get_SN():String 
	{
		return AnimationData.setFieldBool(this, ["SN", "SYMBOL_name"]);
	}
	function get_N():String
	{
		return AnimationData.setFieldBool(this, ["N", "name"]);
	}
	function get_TL():Timeline
	{
		return AnimationData.setFieldBool(this, ["TL", "TIMELINE"]);
	}
	function get_STI()
	{
		return AnimationData.setFieldBool(this, ["STI", "StageInstance"]);
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
		return AnimationData.setFieldBool(this, ["SI", "SYMBOL_Instance"]);
	}
}
/**
 * the SymbolData that the symbol has for checking stuff
 */
abstract SymbolData({}) from {}
{
	/**
	 * The name of the symbol
	 */
	public var SN(get, never):String;
	/**
	 * The timeline of the Symbol, aka the frames of the symbols, with all the layers and stuff
	 */
	public var TL(get, never):Timeline;


	function get_SN():String 
	{
		return AnimationData.setFieldBool(this, ["SN", "SYMBOL_name"]);
	}
	function get_TL():Timeline
	{
		return AnimationData.setFieldBool(this, ["TL", "TIMELINE"]);
	}
}
/**
 * The timeline that the animation is based
 */
abstract Timeline({}) from {}
{
	/**
	 * The layers that are in the timeline
	 */
	public var L(get, set):Array<Layers>;


	function get_L():Array<Layers>
	{
		return AnimationData.setFieldBool(this, ["L", "LAYERS"]);
	}
	function set_L(value:Array<Layers>)
	{
		return AnimationData.setFieldBool(this, ["L", "LAYERS"], value);
	}
}
/**
 * the Layer abstract, nothing much to say here
 */
abstract Layers({}) from {}
{
	/**
	 * The name of the layer.
	 */
	public var LN(get, never):String;
	/**
	 * Type of layer. Usually it's just to announce that the layer is a mask.
	 */
	public var LT(get, never):String;
	/**
	 * To which layer it is clipped.
	 */
	public var Clpb(get, never):String;
	/**
	 * The frames that the layer has.
	 */
	public var FR(get, set):Array<Frame>;


	function get_LN():String
	{
		return AnimationData.setFieldBool(this, ["LN", "Layer_name"]);
	}
	function get_LT():String
	{
		return AnimationData.setFieldBool(this, ["LT", "Layer_type"]);
	}
	function get_Clpb():String
	{
		return AnimationData.setFieldBool(this, ["Clpb", "Clipped_by"]);
	}
	function get_FR():Array<Frame>
	{
		return AnimationData.setFieldBool(this, ["FR", "Frames"]);
	}
	function set_FR(value:Array<Frame>):Array<Frame>
	{
		return AnimationData.setFieldBool(this, ["FR", "Frames"], value);
	}
}
/**
 * Only has the framerate for some reason
 */
abstract MetaData({}) from {}
{
	
	/**
	 * Framerate of the anim, nothing much here.
	 */
	public var FRT(get, never):Float;
	
	function get_FRT()
	{
		return AnimationData.setFieldBool(this, ["FRT", "framerate"]);
	}
}
/**
 * the frame abstract that has the essential
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
	public var C(get, set):ColorEffects;


	/**
	 * Filter stuff, this is the reason why you can't add custom shaders, srry
	 */
	public var F(get, never):Filters;


	function get_N():String
	{
		return AnimationData.setFieldBool(this, ["N", "name"]);
	}
	function get_I():Int
	{
		return AnimationData.setFieldBool(this, ["I", "index"]);
	}
	function get_DU():Int
	{
		return AnimationData.setFieldBool(this, ["DU", "duration"]);
	}
	function get_E():Array<Element>
	{
		return AnimationData.setFieldBool(this, ["E", "elements"]);
	}
	function get_C()
	{
		return AnimationData.setFieldBool(this, ["C", "color"]);
	}
	function set_C(value:ColorEffects)
	{
		return AnimationData.setFieldBool(this, ["C", "color"], value);
	}


	function get_F()
	{
		return AnimationData.setFieldBool(this, ["F", "filters"]);
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
		return AnimationData.setFieldBool(this, ["ASI", "ATLAS_SPRITE_instance"]);
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
	 * The Matrix of the Symbol, Be aware from Neo! He can be anywhere!!! :fearful:
	 */
	public var M3D(get, never):OneOfTwo<Array<Float>, Matrix3D>;
	/**
	 * The Color Effect of the symbol, it says color but it affects alpha too lol.
	 */
	public var C(get, set):ColorEffects;


	/**
	 * Filter stuff, this is the reason why you can't add custom shaders, srry
	 */
	public var F(get, never):Filters;


	function get_SN()
	{
		return AnimationData.setFieldBool(this, ["SN", "SYMBOL_name"]);
	}


	function get_IN()
	{
		return AnimationData.setFieldBool(this, ["IN", "Instance_Name"]);
	}


	function get_ST()
	{
		return AnimationData.setFieldBool(this, ["ST", "symbolType"]);
	}


	function get_bitmap()
	{
		return AnimationData.setFieldBool(this, ["BM", "bitmap"]);
	}
	function get_FF()
	{
		return AnimationData.setFieldBool(this, ["FF", "firstFrame"]);
	}


	function get_LP()
	{
		return AnimationData.setFieldBool(this, ["LP", "loop"]);
	}


	function get_TRP()
	{
		return AnimationData.setFieldBool(this, ["TRP", "transformationPoint"]);
	}


	function get_M3D()
	{
		return AnimationData.setFieldBool(this, ["M3D", "Matrix3D"]);
	}


	function get_C()
	{
		return AnimationData.setFieldBool(this, ["C", "color"]);
	}
	function set_C(value:ColorEffects)
	{
		return AnimationData.setFieldBool(this, ["C", "color"], value);
	}


	function get_F()
	{
		return AnimationData.setFieldBool(this, ["F", "filters"]);
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
		return AnimationData.setFieldBool(this, ["M", "mode"]);
	}
	function get_TC()
	{
		return AnimationData.setFieldBool(this, ["TC", "tintColor"]);
	}
	function get_TM()
	{
		return AnimationData.setFieldBool(this, ["TM", "tintMultiplier"]);
	}
	function get_AM()
	{
		return AnimationData.setFieldBool(this, ["AM", "alphaMultiplier"]);
	}
	function get_AO()
	{
		return AnimationData.setFieldBool(this, ["AO", "AlphaOffset"]);
	}
	function get_RM()
	{
		return AnimationData.setFieldBool(this, ["RM", "RedMultiplier"]);
	}
	function get_RO()
	{
		return AnimationData.setFieldBool(this, ["RO", "redOffset"]);
	}
	function get_GM()
	{
		return AnimationData.setFieldBool(this, ["GM", "greenMultiplier"]);
	}
	function get_GO()
	{
		return AnimationData.setFieldBool(this, ["GO", "greenOffset"]);
	}
	function get_BM()
	{
		return AnimationData.setFieldBool(this, ["BM", "blueMultiplier"]);
	}
	function get_BO()
	{
		return AnimationData.setFieldBool(this, ["BO", "blueOffset"]);
	}
	function get_BRT()
	{
		return AnimationData.setFieldBool(this, ["BRT", "Brightness"]);
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
		return AnimationData.setFieldBool(this, ["ACF", "AdjustColorFilter"]);
	}
	function get_GF()
	{
		return AnimationData.setFieldBool(this, ["GF"]);
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
		return AnimationData.setFieldBool(this, ["BRT", "brightness"]);
	}
	function get_CT()
	{
		return AnimationData.setFieldBool(this, ["CT", "contrast"]);
	}
	function get_SAT()
	{
		return AnimationData.setFieldBool(this, ["SAT", "saturation"]);
	}
	function get_H()
	{
		return AnimationData.setFieldBool(this, ["H", "hue"]);
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
		return AnimationData.setFieldBool(this, ["BLX", "blurX"]);
	}
	function get_BLY()
	{
		return AnimationData.setFieldBool(this, ["BLY", "blurY"]);
	}
	function get_Q()
	{
		return AnimationData.setFieldBool(this, ["Q", "quality"]);
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
		return AnimationData.setFieldBool(this, ["C"]);
	}
	function get_A()
	{
		return AnimationData.setFieldBool(this, ["A"]);
	}
	function get_STR()
	{
		return AnimationData.setFieldBool(this, ["STR"]);
	}
	function get_KK()
	{
		return AnimationData.setFieldBool(this, ["KK"]);
	}
	function get_IN()
	{
		return AnimationData.setFieldBool(this, ["IN"]);
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
		return AnimationData.setFieldBool(this, ["N", "name"]);
	}
	function get_POS()
	{
		return AnimationData.setFieldBool(this, ["POS", "Position"]);
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


	function get_M3D()
	{
		return AnimationData.setFieldBool(this, ["M3D", "Matrix3D"]);
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