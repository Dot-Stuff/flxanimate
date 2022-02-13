package flxanimate.data;

@:noCompletion
class AnimationData
{
	public static var version:String = "";

	@:noCompletion
	public static function parseDurationFrames(frames:Array<Frame>):Array<Frame>
	{
		var result:Array<Frame> = [];

		for (frame in frames)
		{
			var i = 0;

			do
			{
				result.push(frame);
				i++;
			}
			while (i < frame.DU);
		}

		return result;
	}

	@:noCompletion
	public static function setFieldBool(abstracto:Dynamic, thing1:String, thing2:String):Dynamic
	{
		// TODO: The comment below this comment.
		// GeoKureli told me that Reflect is shit, but I have literally no option but to use this.
		// If I have another thing to use that works the same, should replace this lol
		return if (Reflect.hasField(abstracto, thing1))
		{
			Reflect.field(abstracto, thing1);
		}
		else
		{
			Reflect.field(abstracto, thing2);
		}
	}
}

abstract AnimAtlas({})
{
	/**
	 * The main thing, the animation that makes the different drawings animate together and shit
	 */
	public var AN(get, never):Animation;

	/**
	 * This collects the symbols and gets it into weird stuff so it can be used on the anim, **WARNING:** Can be `Null` or `undefined`
	 */
	public var SD(get, never):SymbolDictionary;

	/**
	 * Minor stuff, this checks the framerate the anim is and nothing much tbh
	 */
	public var MD(get, never):MetaData;

	inline function get_AN():Animation
	{
		return AnimationData.setFieldBool(this, "AN", "ANIMATION");
	}

	inline function get_MD():MetaData
	{
		return AnimationData.setFieldBool(this, "MD", "metadata");
	}

	inline function get_SD()
	{
		return AnimationData.setFieldBool(this, "SD", "SYMBOL_DICTIONARY");
	}
}

/**
 * The list of symbols that the anim uses
 */
abstract SymbolDictionary({})
{
	/**
	 * The list of Symbols used in an animation
	 */
	public var S(get, never):Array<SymbolData>;

	inline function get_S():Array<SymbolData>
	{
		return AnimationData.setFieldBool(this, "S", "Symbols");
	}
}

/**
 * The main animation Thing
 */
abstract Animation({})
{
	/**
	 * The name of the symbol
	 */
	public var SN(get, never):String;

	/**
	 * The name of the document which was exported
	 */
	public var N(get, never):String;

	/**
	 * The timeline of the animation which was exported
	 */
	public var TL(get, never):Timeline;

	/**
	 * Optional: Some docs have an STI, which idk what is it tbh
	 */
	public var STI(get, never):{public var SI:SymbolInstance;};

	inline function get_SN():String
	{
		return AnimationData.setFieldBool(this, "SN", "SYMBOL_name");
	}

	inline function get_N():String
	{
		return AnimationData.setFieldBool(this, "N", "name");
	}

	inline function get_TL():Timeline
	{
		return AnimationData.setFieldBool(this, "TL", "TIMELINE");
	}

	inline function get_STI()
	{
		return AnimationData.setFieldBool(this, "STI", "StageInstance");
	}
}

/**
 * the SymbolData that the symbol has for checking stuff
 */
abstract SymbolData({})
{
	/**
	 * The name of the symbol
	 */
	public var SN(get, never):String;

	/**
	 * The timeline of the Symbol, aka the frames of the symbols, with all the layers and stuff
	 */
	public var TL(get, never):Timeline;

	inline function get_SN():String
	{
		return AnimationData.setFieldBool(this, "SN", "SYMBOL_name");
	}

	inline function get_TL():Timeline
	{
		return AnimationData.setFieldBool(this, "TL", "TIMELINE");
	}
}

/**
 * The timeline that the animation is based
 */
abstract Timeline({})
{
	/**
	 * The layers that are in the timeline
	 */
	public var L(get, never):Array<Layers>;

	inline function get_L():Array<Layers>
	{
		return AnimationData.setFieldBool(this, "L", "LAYERS");
	}
}

/**
 * the Layer abstract, nothing much to say here
 */
abstract Layers({})
{
	/**
	 * The name of the layer.
	 */
	public var LN(get, never):String;

	/**
	 * The frames that the layer has.
	 */
	public var FR(get, never):Array<Frame>;

	inline function get_LN():String
	{
		return AnimationData.setFieldBool(this, "LN", "Layer_name");
	}

	inline function get_FR():Array<Frame>
	{
		return AnimationData.setFieldBool(this, "FR", "Frames");
	}
}

/**
 * Only has the framerate for some reason
 */
abstract MetaData({})
{
	/**
	 * Framerate of the anim, nothing much here.
	 */
	public var FRT(get, never):Float;

	inline function get_FRT()
	{
		return AnimationData.setFieldBool(this, "FRT", "framerate");
	}
}

/**
 * the frame abstract that has the essential
 */
abstract Frame({})
{
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

	inline function get_I():Int
	{
		return AnimationData.setFieldBool(this, "I", "index");
	}

	inline function get_DU():Int
	{
		return AnimationData.setFieldBool(this, "DU", "duration");
	}

	inline function get_E():Array<Element>
	{
		return AnimationData.setFieldBool(this, "E", "elements");
	}
}

/**
 * The Element thing inside the frame
 */
abstract Element({})
{
	/**
	 * the Symbol that it's used.
	 */
	public var SI(get, never):SymbolInstance;

	/**
	 * the Sprite of the animation, aka the non Symbol.
	 */
	public var ASI(get, never):AtlasSymbolInstance;

	inline function get_SI():SymbolInstance
	{
		return AnimationData.setFieldBool(this, "SI", "SYMBOL_Instance");
	}

	inline function get_ASI():AtlasSymbolInstance
	{
		return AnimationData.setFieldBool(this, "ASI", "ATLAS_SPRITE_instance");
	}
}

/**
 * The Symbol Abstract
 */
abstract SymbolInstance({})
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
	 * the first frame that is is beginning with. mainly for graphics
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
	public var M3D(get, never):Array<Float>;

	inline function get_SN():String
	{
		return AnimationData.setFieldBool(this, "SN", "SYMBOL_name");
	}

	inline function get_IN():String
	{
		return AnimationData.setFieldBool(this, "IN", "Instance_Name");
	}

	inline function get_ST():SymbolType
	{
		if (Reflect.hasField(this, "ST"))
		{
			return Reflect.field(this, "ST");
		}
		else
		{
			switch (Reflect.field(this, "symbolType"))
			{
				case "graphic":
					return GRAPHIC;
				case "movieclip":
					return MOVIE_CLIP;
				case "button":
					return BUTTON;
				default:
					return null;
			}
		}
	}

	inline function get_FF():Int
	{
		return AnimationData.setFieldBool(this, "FF", "firstFrame");
	}

	inline function get_LP():LoopType
	{
		if (Reflect.hasField(this, "LP"))
		{
			return Reflect.field(this, "LP");
		}
		else
		{
			switch (Reflect.field(this, "loop"))
			{
				case "loop":
					return LOOP;
				case "playonce":
					return PLAY_ONCE;
				case "singleframe":
					return SINGLE_FRAME;
				default:
					return null;
			}
		}
	}

	inline function get_TRP():TransformationPoint
	{
		return AnimationData.setFieldBool(this, "TRP", "transformationPoint");
	}

	inline function get_M3D()
	{
		if (Reflect.hasField(this, "M3D"))
		{
			return Reflect.field(this, "M3D");
		}
		else
		{
			// Don't wanna have useless typedefs srry
			var matrix = Reflect.field(this, "Matrix3D");
			return [
				matrix.m00, matrix.m01, matrix.m02, matrix.m03, matrix.m10, matrix.m11, matrix.m12, matrix.m13, matrix.m20, matrix.m21, matrix.m22,
				matrix.m23, matrix.m30, matrix.m31, matrix.m32, matrix.m33
			];
		}
	}
}

/**
 * The Sprite/Drawing abstract
 */
abstract AtlasSymbolInstance({})
{
	/**
	 * The name of the drawing, basically determines which one of the sprites on spritemap should be used.
	 */
	public var N(get, never):String;

	/**
	 * The matrix of the Sprite, Neo should be here at any second!!!
	 */
	public var M3D(get, never):Array<Float>;

	inline function get_N()
	{
		return AnimationData.setFieldBool(this, "N", "name");
	}

	inline function get_M3D()
	{
		if (Reflect.hasField(this, "M3D"))
		{
			return Reflect.field(this, "M3D");
		}
		else
		{
			// This is cause I don't want unnecessary typedefs lol
			var matrix = Reflect.field(this, "Matrix3D");
			return [
				matrix.m00, matrix.m01, matrix.m02, matrix.m03, matrix.m10, matrix.m11, matrix.m12, matrix.m13, matrix.m20, matrix.m21, matrix.m22,
				matrix.m23, matrix.m30, matrix.m31, matrix.m32, matrix.m33
			];
		}
	}
}

/**
 * The position of the pivot for making the matrix go good or bad.
 */
typedef TransformationPoint =
{
	/**
	 * The x Axis of the TRP
	 */
	var x:Float;

	/**
	 * The Y axis of the TRP
	 */
	var y:Float;
}

typedef Filters =
{
	var BLF:BlurFilterS;
}

typedef BlurFilterS =
{
	var BLX:Float;
	var BLY:Float;
	var Q:Int;
}

enum abstract LoopType(String) from String to String
{
	var LOOP = "LP";
	var PLAY_ONCE = "PO";
	var SINGLE_FRAME = "SF";
}

enum abstract SymbolType(String) from String to String
{
	var GRAPHIC = "G";
	var MOVIE_CLIP = "MC";
	var BUTTON = "B";
}
