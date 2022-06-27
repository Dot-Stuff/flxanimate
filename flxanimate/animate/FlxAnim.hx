package flxanimate.animate;

import openfl.geom.ColorTransform;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.FlxG;
import flixel.math.FlxMatrix;
import flxanimate.data.AnimationData;
#if FLX_SOUND_SYSTEM
import flixel.system.FlxSound;
#end

typedef SymbolStuff = {var symbol:FlxSymbol; var ?indices:Array<Int>; var X:Float; var Y:Float; var frameRate:Float; var looped:Bool;};
typedef ClickStuff = {
	?OnClick:Void->Void,
	?OnRelease:Void->Void
}
typedef ButtonSettings = {
	?Callbacks:ClickStuff,
	#if FLX_SOUND_SYSTEM
	?Sound:FlxSound
	#end
}
class FlxAnim implements IFlxDestroyable
{
	public var xFlip(default, set):Bool;
	public var yFlip(default, set):Bool;
	public var coolParse(default, null):AnimAtlas;
	public var length(get, never):Int;

	public var curSymbol:FlxSymbol;
	public var finished(default, null):Bool = false;
	public var reversed:Bool = false;
	
	public var colorTransform:ColorTransform;
	var buttonMap:Map<String, ButtonSettings> = new Map();
	/**
	 * When ever the animation is playing.
	 */
	public var isPlaying(default, null):Bool = false;
	public var onComplete:()->Void;

	public var width:Int;
	public var height:Int;

	var _matrix:FlxMatrix;

	var frameTick:Float;
	public var framerate(default, set):Float;

	/**
	 * Internal, used for each skip between frames.
	 */
	var frameDelay:Float;

	public var curFrame(get, set):Int;

	var animsMap:Map<String, SymbolStuff> = new Map();
	
	/**
	 * Internal, the parsed loop type
	 */
	var loopType(default, null):LoopType = loop;

	public var symbolType:SymbolType = "G";

	/**
	 * Add a new
	 *
	 * @param coolParsed 	The Animation.json file
	 */
	public function new(coolParsed:AnimAtlas)
	{
		coolParse = coolParsed;
		_matrix = new FlxMatrix();
		width = height = 0;
		colorTransform = new ColorTransform();
	}

	public var symbolDictionary:Map<String, FlxSymbol> = new Map<String, FlxSymbol>();
	
	public function play(?Name:String, Force:Bool = false, Reverse:Bool = false, Frame:Int = 0)
	{
		pause();
		var curThing = animsMap.get(Name);
		if ([null, ""].indexOf(Name) == -1 && curThing == null)
		{
			FlxG.log.error('theres no animation called $Name!');
			isPlaying = true;
			return;
		}
		if ([null, ""].indexOf(Name) != -1)
		{
			reversed = Reverse;
			finished = false;
			isPlaying = true;
			return;
		}
		@:privateAccess
		if ([null, ""].indexOf(Name) == -1)
		{
			_matrix.identity();
			if (Name == coolParse.AN.SN && coolParse.AN.STI != null)
				_matrix.concat(curSymbol.prepareMatrix(coolParse.AN.STI.SI.M3D));
			curFrame = 0;
			curSymbol = curThing.symbol;
			curFrame = (Reverse) ? Frame - length : Frame;
			@:privateAccess
			loopType = curThing.looped ? loop : playonce;
		}
		if (Force || finished)
		{
			curFrame = (Reverse) ? Frame - length : Frame;
		}
		reversed = Reverse;
		finished = false;
		isPlaying = true;
	}

	public function pause()
	{
		isPlaying = false;
	}
	public function stop()
	{
		pause();
		curFrame = 0;
	}

	var pressed:Bool = false;

	function setSymbols(Anim:AnimAtlas)
	{
		if (Anim.AN.STI != null)
		{
			var SI = Anim.AN.STI.SI;
			SI.M3D = (SI.M3D is Array) ? SI.M3D : [SI.M3D.m00, SI.M3D.m01,SI.M3D.m02,SI.M3D.m03,SI.M3D.m10,SI.M3D.m11,SI.M3D.m12,SI.M3D.m13,SI.M3D.m20,SI.M3D.m21,SI.M3D.m22,
				SI.M3D.m23,SI.M3D.m30,SI.M3D.m31,SI.M3D.m32,SI.M3D.m33];
		}
		curSymbol = new FlxSymbol(Anim.AN.SN, Anim.AN.TL, true);
		symbolDictionary.set(Anim.AN.SN, curSymbol);
		if (coolParse.SD != null)
		{
			for (symbol in coolParse.SD.S)
			{
				symbolDictionary.set(symbol.SN, new FlxSymbol(symbol.SN, symbol.TL, true));
			}
		}	
	}
	public function setShit()
	{
		setSymbols(coolParse);
		if (coolParse.AN.STI != null)
		{
			var STI = coolParse.AN.STI.SI;
			loopType = STI.LP;
			symbolType = STI.ST;
			curFrame = STI.FF;
			_matrix.concat(curSymbol.prepareMatrix(STI.M3D));
			
			if (STI.C != null)
			{
				@:privateAccess
				colorTransform = FlxAnimate.colorEffect(STI.C);
			}
		}
	}

	public function update(elapsed:Float)
	{
		curFrame = curSymbol.frameControl(curFrame, loopType);
		if (!isPlaying || finished) return;

		frameTick += elapsed;
		while (frameTick > frameDelay)
		{
			curSymbol.update((reversed) ? -1 : 1, loopType);
			frameTick -= frameDelay;
		}
		finished = (reversed && curFrame == 0 || curFrame == length);

		if ([playonce, "playonce"].indexOf(loopType) != -1)
		{
			if (finished)
			{
				if (onComplete != null)
					onComplete();
				pause();
			}
		}
	}
	var oldMatrix:FlxMatrix;
	function set_xFlip(Value:Bool)
	{
		if (oldMatrix == null)
		{
			oldMatrix = new FlxMatrix();
			oldMatrix.concat(_matrix);
		}
		if (Value)
		{
			_matrix.a = -oldMatrix.a;
			_matrix.c = -oldMatrix.c;
			_matrix.tx += width;
		}
		else
		{
			_matrix.a = oldMatrix.a;
			_matrix.c = oldMatrix.c;
			_matrix.tx = (_matrix.tx == oldMatrix.tx + width) ? oldMatrix.tx : _matrix.tx; 
		}
		return Value;
	}
	function set_yFlip(Value:Bool)
	{
		if (oldMatrix == null)
		{
			oldMatrix = new FlxMatrix();
			oldMatrix.concat(_matrix);
		}
		if (Value)
		{
			_matrix.b = -oldMatrix.b;
			_matrix.d = -oldMatrix.d;
			_matrix.translate(0, height);
		}
		else
		{
			_matrix.b = oldMatrix.b;
			_matrix.d = oldMatrix.d;
			_matrix.ty = (_matrix.ty == oldMatrix.ty + height) ? oldMatrix.ty : _matrix.ty; 
		}
		return Value;
	}
	function get_curFrame()
	{
		return curSymbol.curFrame;
	}
	function set_curFrame(Value:Int)
	{
		return curSymbol.curFrame = Value;
	}
	/**
	 * Creates an animation using an already made symbol from a texture atlas
	 * @param Name The name of the animation
	 * @param SymbolName the name of the symbol you're looking. if you have two symbols beginning by the same name, use `\` at the end to differ one symbol from another
	 * @param X the *x* axis of the animation.
	 * @param Y  the *y* axis of the animation.
	 * @param FrameRate the framerate of the animation.
	 */
	public function addBySymbol(Name:String, SymbolName:String, FrameRate:Float = 30, Looped:Bool = true, X:Float = 0, Y:Float = 0)
	{
		var timeline:Timeline = null;
		for (name in symbolDictionary.keys())
		{
			if (startsWith(name, SymbolName))
			{
				timeline = symbolDictionary.get(name);
				break;
			}
		}
		if (timeline != null)
			animsMap.set(Name, {symbol: new FlxSymbol(Name, timeline), X: X, Y: Y, frameRate: FrameRate, looped: Looped});
		else
			FlxG.log.error('No symbol was found with the name $SymbolName!');
	}
	function startsWith(reference:String, string:String):Bool
	{
		if (StringTools.endsWith(string, String.fromCharCode(92))) // String.fromCharCode(92) == \ :)
			return reference == string.substring(0, string.length - 1)
		else
			return StringTools.startsWith(reference, string);
	}
	/**
	 * Creates an animation using the indices, looking as a reference the main animation of the texture atlas.
	 * @param Name The name of the animation you're creating
	 * @param Indices The indices you're gonna be using for the animation, like `[0,1,2]`.
	 * @param FrameRate the framerate of the animation.
	 */
	public function addByAnimIndices(Name:String, Indices:Array<Int>, FrameRate:Float = 30) 
	{
		addBySymbolIndices(Name, coolParse.AN.SN, Indices, FrameRate, (coolParse.AN.STI != null) ? ["loop", "LP"].indexOf(coolParse.AN.STI.SI.LP) != -1 : false, 0,0);
	}
	public function addBySymbolIndices(Name:String, SymbolName:String, Indices:Array<Int>, FrameRate:Float = 30, Looped:Bool = true, X:Float = 0, Y:Float = 0) 
	{
		var thing = symbolDictionary.get(SymbolName);
		if (thing == null)
		{
			FlxG.log.error('$SymbolName does not exist as a symbol! maybe you misspelled it?');
			return;
		}
		var layers:Array<Layers> = [];
		for (layer in thing.timeline.L)
		{
			var frames:Array<Frame> = [];
			for (i in Indices)
			{
				if (layer.FR[i] != null)
					frames.push(layer.FR[i]);
			}
			layers.push({LN: layer.LN, FR: frames});
		}


		animsMap.set(Name, {symbol: new FlxSymbol(Name, {L: layers}), indices: Indices, X: X, Y: Y, frameRate: FrameRate, looped: false});
	}

	function set_framerate(value:Float):Float
	{
		frameDelay = 1 / value;
		return framerate = value;
	}
	/**
	 * This adds a new animation by adding a custom timeline, obviously taking as a reference the timeline syntax!
	 * **WARNING**: I, *CheemsAndFriends*, do **NOT** recommend this unless you're using an extern json file to do this!
	 * if you wanna make a custom symbol to play around and is separated from the texture atlas, go ahead! but if you wanna just make a new symbol, 
	 * just do it in Flash directly
	 * @param Name The name of the new Symbol.
	 * @param Timeline The timeline which will have the symbol.
	 * @param FrameRate The framerate it'll go, by default is 30.
	 */
	public function addByCustomTimeline(Name:String, Timeline:Timeline, FrameRate:Float = 30, Looped:Bool = true)
	{
		animsMap.set(Name, {symbol: new FlxSymbol(Name, Timeline, true), X: 0, Y: 0, frameRate: FrameRate, looped: Looped});
	}

	public function get_length()
	{
		return curSymbol.length;
	}

	public function getFrameLabel(name:String):Null<FlxLabel>
	{
		var thingy = curSymbol.labels.get(name);

		if (thingy == null)
		{
			FlxG.log.error('The frame label "$name" does not exist! maybe you misspelled it?');
		}
		return thingy;
	}
	/**
	 * Redirects the frame into a frame with a frame label of that type.
	 * @param name the name of the label.
	 */
	public function goToFrameLabel(name:String)
	{
		var label = getFrameLabel(name);

		if (label != null)
			curFrame = label.frame;
	}
	/**
	 * Checks the next frame label name you're looking for.
	 * **WARNING: DO NOT** confuse with `anim.curSymbol.getNextToFrameLabel`!!
	 * @param name the name of the frame label.
	 * @return A `String`. WARNING: it can be `null`
	 */
	public function getNextToFrameLabel(name:String):Null<String>
	{
		return curSymbol.getNextToFrameLabel(name).name;
	}
	/**
	 * Links a callback into a label.
	 * @param label the name of the label.
	 * @param callback the callback you're going to add 
	 */
	public function addCallbackTo(label:String, callback:()->Void)
	{
		curSymbol.addCallbackTo(label, callback);
	}

	public function removeCallbackFrom(label:String, callback:()->Void)
	{
		curSymbol.removeCallbackFrom(label, callback);
	}

	public function removeAllCallbacksFrom(label:String)
	{
		curSymbol.removeAllCallbacksFrom(label);
	}

	
	public function getByName(name:String)
	{
		return animsMap.get(name);
	}
	public function destroy()
	{
		xFlip = yFlip = false;
		coolParse = null;
		curFrame = 0;
		framerate = 0;
		frameTick = 0;
		animsMap = null;
		loopType = null;
		symbolType = null;
		symbolDictionary = null;
	}
}