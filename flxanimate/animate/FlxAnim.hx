package flxanimate.animate;

import openfl.geom.ColorTransform;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMatrix;
import flxanimate.data.AnimationData;
#if FLX_SOUND_SYSTEM
import flixel.system.FlxSound;
#end

typedef SymbolStuff = {var symbolName:String; var timeline:Timeline; var ?indices:Array<Int>; var X:Float; var Y:Float; var frameRate:Float; var looped:Bool;};
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
class FlxAnim extends FlxSprite
{
	public var xFlip(default, set):Bool;
	public var yFlip(default, set):Bool;
	public var coolParse(default, null):AnimAtlas;
	public var length(get, never):Int;
	public var timeline:Timeline = null;
	var frameLabels:Map<String, Int> = new Map();
	var labelArray:Map<String, String> = new Map();
	var labelcallbacks:Map<String, Array<()->Void>> = new Map();
	public var finished(default, null):Bool = false;
	public var reversed:Bool = false;
	var buttonMap:Map<String, ButtonSettings> = new Map();
	public var isPlaying(default, null):Bool = false;
	public var onComplete:()->Void;
	var layerHide:Map<String, Array<String>> = new Map();

	var frameTick:Float;
	public var framerate(default, set):Float;

	/**
	 * Internal, used for each skip between frames.
	 */
	var frameDelay:Float;

	var symbolName:String;

	public var curFrame:Int = 0;

	var animsMap:Map<String, SymbolStuff> = new Map();
	
	var callbackCalled:Bool = false;
	/**
	 * Internal, the parsed loop type
	 */
	var loopType(default, null):LoopType = loop;

	public var symbolType:SymbolType = "G";
	
	var frameLength:Int = 1;

	var curLabel:Null<String> = null; 

	/**
	 * Add a new texture atlas sprite
	 * 
	 * @param x 			the X axis
	 * @param y 			the Y axis
	 * @param coolParsed 	The Animation.json file
	 */
	public function new(x:Float, y:Float, coolParsed:AnimAtlas)
	{
		super(x, y);
		coolParse = coolParsed;
	}

	public function render()
	{
		for (layer in timeline.L)
		{

			if ([button, "button"].indexOf(symbolType) != -1)
			{
				setButtonFrames();
			}
			if (curFrame < 0)
			{
				if ([loop, "loop"].indexOf(loopType) != -1)
					curFrame += (length > 0) ? frameLength : curFrame;
				else
				{
					curFrame = 0;
					finished = true;
				}
			}
			else if (curFrame > frameLength - 1)
			{
				if ([loop, "loop"].indexOf(loopType) != -1)
				{
					curFrame -= (frameLength > 0) ? frameLength : curFrame;
				}
				else
				{
					curFrame = frameLength;
					finished = true;
					pause();
				}
			}
			else
				finished = false;

			if (layerHide.exists(symbolName) && layerHide.get(symbolName).indexOf(layer.LN) != -1) continue;
			
			var selectedFrame = layer.FR[curFrame];
			curLabel = (selectedFrame != null) ? selectedFrame.N : null;
		
			if (selectedFrame == null || selectedFrame.E == []) continue;

			for (element in selectedFrame.E)
			{
				var inst:FlxInstance = new FlxInstance(this,  element.SI);
				inst.limb = (inst.isSymbol) ? element.SI.bitmap.N : element.ASI.N;
				var m3d = (inst.isSymbol) ? element.SI.M3D : element.ASI.M3D;
				var matrix:FlxMatrix = new FlxMatrix(m3d[0], m3d[1], m3d[4], m3d[5], m3d[12], m3d[13]);
				matrix.concat(_matrix);
				inst._matrix.concat(matrix);

				setSize((width < inst.width) ? inst.width : width, (height < inst.height) ? inst.height : height);
				inst.render();
			}
		}
	}

	public var symbolDictionary:Map<String, Timeline> = new Map<String, Timeline>();
	public function play(?Name:String, Force:Bool = false, Reverse:Bool = false, Frame:Int = 0)
	{
		pause();
		var curThing = animsMap.get(Name);
		@:privateAccess
		if (curThing != null && symbolName != curThing.symbolName|| Force || !Reverse && curFrame >= length || Reverse && curFrame <= 0)
		{
			if (!Reverse)
				curFrame = Frame;
			else
				curFrame =  Frame - length;
		}
		@:privateAccess
		if ([null, ""].indexOf(Name) == -1)
		{
			if (curThing == null)
			{
				FlxG.log.error('theres no animation called $Name!');
				return;
			}
			frameLength = 0;
			for (layer in curThing.timeline.L)
			{
				if (frameLength < layer.FR.length)
				{
					frameLength = layer.FR.length;
				}
			}
			timeline = curThing.timeline;
			@:privateAccess
			loopType = curThing.looped ? loop : playonce;
			@:privateAccess
			symbolName = curThing.symbolName;
		}
		
		reversed = Reverse;
		isPlaying = true;
	}
	public function hideLayer(layer:String)
	{
		var hasLayer:Bool = false;
		for (i in timeline.L)
		{
			if (layer == i.LN)
			{
				hasLayer = true;
				break;
			}
		}
		if (!hasLayer) return;
		var array = (layerHide.get(symbolName) != null) ? layerHide.get(symbolName) : [];
		array.push(layer);
		layerHide.set(symbolName, array);
	}
	public function showLayer(layer:String)
	{
		if (layerHide.get(symbolName) == null) return;
		layerHide.get(symbolName).remove(layer);
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

	function addColorEffect(sInstance:ColorEffects)
	{
		var CT = new ColorTransform();
		switch (sInstance.M)
		{
			case Tint, "Tint":
			{
				var color = flixel.util.FlxColor.fromString(sInstance.TC);
				var opacity = sInstance.TM;
				CT.redMultiplier -= opacity;
				CT.redOffset = Math.round(color.red * opacity);
				CT.greenMultiplier -= opacity;
				CT.greenOffset = Math.round(color.green * opacity);
				CT.blueMultiplier -= opacity;
				CT.blueOffset = Math.round(color.blue * opacity);
			}
			case Alpha, "Alpha":
			{
				CT.alphaMultiplier = sInstance.AM;
			}
			case Brightness, "Brightness":
			{
				CT.redMultiplier = CT.greenMultiplier = CT.blueMultiplier -= Math.abs(sInstance.BRT);
				if (sInstance.BRT >= 0)
					CT.redOffset = CT.greenOffset = CT.blueOffset = 255 * sInstance.BRT;
			}
			case Advanced, "Advanced":
			{
				CT.redMultiplier = sInstance.RM;
				CT.redOffset = sInstance.RO;
				CT.greenMultiplier = sInstance.GM;
				CT.greenOffset = sInstance.GO;
				CT.blueMultiplier = sInstance.BM;
				CT.blueOffset = sInstance.BO;
				CT.alphaMultiplier = sInstance.AM;
				CT.alphaOffset = sInstance.AO;
			}
		}
		
		colorTransform.concat(CT);
	}
	var pressed:Bool = false;
	function setButtonFrames()
	{
		var badPress:Bool = false;
		var goodPress:Bool = false;
		if (FlxG.mouse.pressed && FlxG.mouse.overlaps(this))
			goodPress = true;
		if (FlxG.mouse.pressed && !FlxG.mouse.overlaps(this) && !goodPress)
		{
			badPress = true;
		}
		if (!FlxG.mouse.pressed)
		{
			badPress = false;
			goodPress = false;
		}
		if (FlxG.mouse.overlaps(this) && !badPress)
		{
			var event = buttonMap.get(symbolName);
			if (FlxG.mouse.justPressed && !pressed)
			{
				if (event != null)
					new ButtonEvent((event.Callbacks != null) ? event.Callbacks.OnClick : null #if FLX_SOUND_SYSTEM, event.Sound #end).fire();
				pressed = true;
			}
			if (FlxG.mouse.pressed)
			{
				curFrame = 2;
			}
			else
			{
				curFrame = 1;
			}
			if (FlxG.mouse.justReleased && pressed)
			{
				if (event != null)
					new ButtonEvent((event.Callbacks != null) ? event.Callbacks.OnRelease : null #if FLX_SOUND_SYSTEM, event.Sound #end).fire();
				pressed = false;
			}
		}
		else
		{
			curFrame = 0;
		}
	}

	function reverseLayers()
	{
		coolParse.AN.TL.L.reverse();

		if (coolParse.SD != null)
		{
			for (a in coolParse.SD.S)
			{
				a.TL.L.reverse();
			}
		}
	}
	function setSymbols(Anim:AnimAtlas)
	{
		for (layer in Anim.AN.TL.L)
		{
			for (fr in layer.FR)
			{
				for (element in fr.E)
				{
					var ASI = element.ASI;
					var SI = element.SI;
					if (ASI != null)
					{
						ASI.M3D = (ASI.M3D != null) ? (ASI.M3D is Array) ? ASI.M3D : [ASI.M3D.m00,ASI.M3D.m01,ASI.M3D.m02,ASI.M3D.m03,ASI.M3D.m10,ASI.M3D.m11,ASI.M3D.m12,ASI.M3D.m13,
							ASI.M3D.m20,ASI.M3D.m21,ASI.M3D.m22,ASI.M3D.m23,ASI.M3D.m30,ASI.M3D.m31,ASI.M3D.m32,ASI.M3D.m33] : [1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1];

						if (ASI.POS != null)
						{
							ASI.M3D[12] += ASI.POS.x;
							ASI.M3D[13] += ASI.POS.y;
						}
					}
					if (SI != null)
					{
						SI.M3D = (SI.M3D is Array) ? SI.M3D : [SI.M3D.m00, SI.M3D.m01,SI.M3D.m02,SI.M3D.m03,SI.M3D.m10,SI.M3D.m11,SI.M3D.m12,SI.M3D.m13,SI.M3D.m20,SI.M3D.m21,SI.M3D.m22,
							SI.M3D.m23,SI.M3D.m30,SI.M3D.m31,SI.M3D.m32,SI.M3D.m33];

						if (SI.bitmap != null)
						{
							SI.M3D[12] += SI.bitmap.POS.x;
							SI.M3D[13] += SI.bitmap.POS.y;
						}
					}
				}
			}
			layer.FR = AnimationData.parseDurationFrames(layer.FR);

			if (frameLength < layer.FR.length)
			{
				frameLength = layer.FR.length;
			}
		}
		frameLength--;
		symbolDictionary.set(Anim.AN.SN, Anim.AN.TL);
		if (coolParse.SD != null)
		{
			for (symbol in coolParse.SD.S)
			{
				for (layer in symbol.TL.L)
				{
					for (fr in layer.FR)
					{
						for (element in fr.E)
						{
							var ASI = element.ASI;
							var SI = element.SI;
							if (ASI != null)
							{
								ASI.M3D = (ASI.M3D != null) ? (ASI.M3D is Array) ? ASI.M3D : [ASI.M3D.m00,ASI.M3D.m01,ASI.M3D.m02,ASI.M3D.m03,ASI.M3D.m10,ASI.M3D.m11,ASI.M3D.m12,ASI.M3D.m13,
									ASI.M3D.m20,ASI.M3D.m21,ASI.M3D.m22,ASI.M3D.m23,ASI.M3D.m30,ASI.M3D.m31,ASI.M3D.m32,ASI.M3D.m33] : [1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1];
		
								if (ASI.POS != null)
								{
									ASI.M3D[12] += ASI.POS.x;
									ASI.M3D[13] += ASI.POS.y;
								}
							}
							if (SI != null)
							{
								SI.M3D = (SI.M3D is Array) ? SI.M3D : [SI.M3D.m00, SI.M3D.m01,SI.M3D.m02,SI.M3D.m03,SI.M3D.m10,SI.M3D.m11,SI.M3D.m12,SI.M3D.m13,SI.M3D.m20,SI.M3D.m21,SI.M3D.m22,
									SI.M3D.m23,SI.M3D.m30,SI.M3D.m31,SI.M3D.m32,SI.M3D.m33];
		
								if (SI.bitmap != null)
								{
									SI.M3D[12] += SI.bitmap.POS.x;
									SI.M3D[13] += SI.bitmap.POS.y;
								}
							}
						}
					}
					layer.FR = AnimationData.parseDurationFrames(layer.FR);
				}
				symbolDictionary.set(symbol.SN, symbol.TL);
			}
		}	
	}
	public function setShit()
	{
		symbolName = coolParse.AN.SN;
		reverseLayers();
		setSymbols(coolParse);
		getFrameLabels(coolParse.AN.TL);
		if (coolParse.AN.STI != null)
		{
			var STI = coolParse.AN.STI.SI;
			loopType = STI.LP;
			symbolType = STI.ST;
			curFrame = STI.FF;
			_matrix.concat(FlxInstance.prepareMatrix(STI.M3D));
			
			if (STI.C != null)
			{
				addColorEffect(STI.C);
			}
		}
		timeline = symbolDictionary.get(symbolName);
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!isPlaying)
			return;
		frameTick += elapsed;
		while (frameTick > frameDelay)
		{
			if (reversed)
			{
				curFrame--;
			}
			else
			{
				curFrame++;
			}
			frameTick -= frameDelay;
		}
		if ([playonce, "playonce"].indexOf(loopType) != -1)
		{
			if (finished)
			{
				if (onComplete != null)
					onComplete();
				stop();	
			}
		}
		if (curLabel != null)
		{
			if (labelcallbacks.exists(curLabel))
			{
				for (callback in labelcallbacks.get(curLabel))
					callback();
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
	function setSymbolLength(TL:Timeline):Int
	{
		var length:Int = 0;
		for (layer in TL.L)
		{
			if (length < layer.FR.length)
			{
				length = layer.FR.length;
			}
		}
		length--;
		return length;
	}
	/**
	 * Creates an animation using an already made symbol from a texture atlas
	 * @param Name The name of the animation
	 * @param SymbolName the name of the symbol you're looking. if you have two symbols beginning by the same name, use `\` at the end
	 * @param X the *x* axis of the animation.
	 * @param Y  the *y* axis of the animation.
	 * @param FrameRate the framerate of the animation.
	 */
	public function addBySymbol(Name:String, SymbolName:String, FrameRate:Float = 30, Looped:Bool = false, X:Float = 0, Y:Float = 0)
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
			animsMap.set(Name, {symbolName: SymbolName, timeline: timeline, X: X, Y: Y, frameRate: FrameRate, looped: Looped});
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
	public function addBySymbolIndices(Name:String, SymbolName:String, Indices:Array<Int>, FrameRate:Float = 30, Looped:Bool = false, X:Float = 0, Y:Float = 0) 
	{
		var thing = symbolDictionary.get(SymbolName);
		if (thing == null)
		{
			FlxG.log.error('$SymbolName does not exist as a symbol! maybe you misspelled it?');
			return;
		}
		var layers:Array<Layers> = [];
		for (layer in thing.L)
		{
			var frames:Array<Frame> = [];
			for (i in Indices)
			{
				if (layer.FR[i] != null)
					frames.push(layer.FR[i]);
			}
			layers.push({LN: layer.LN, FR: frames});
		}

		animsMap.set(Name, {symbolName: SymbolName, timeline: {L: layers}, indices: Indices, X: X, Y: Y, frameRate: FrameRate, looped: false});
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
	public function addByCustomTimeline(Name:String, Timeline:Timeline, FrameRate:Float = 30, Looped:Bool = false)
	{
		for (l in Timeline.L)
		{
			l.FR = AnimationData.parseDurationFrames(l.FR);
		}
		animsMap.set(Name, {symbolName: Name, timeline: Timeline, X: 0, Y: 0, frameRate:FrameRate, looped: Looped});
	}

	public function get_length()
	{
		return frameLength + 1;
	}

	public function getFrameLabel(name:String):Null<Int>
	{
		var thingy = frameLabels.get(name);

		if (thingy == null)
		{
			FlxG.log.error('The frame label called $name does not exist! maybe you misspelled it?');
			return null;
		}
		return thingy;
	}
	/**
	 * Redirects the frame into a frame with a frame label of that type.
	 * @param name the name of the label.
	 */
	public function goToFrameLabel(name:String)
	{
		var framenum = getFrameLabel(name);

		if (framenum != null)
			curFrame = framenum;
	}
	/**
	 * Checks the next frame label you're looking for.
	 * @param name the name of the frame label.
	 * @return A `String`. WARNING: it can be `null`
	 */
	public function getNextToFrameLabel(name:String):Null<String>
	{
		var thing = labelArray.get(name);
		if (thing == null)
			FlxG.log.error('Frame label $name does not exist! Maybe you mispelled it?');
		return thing;
	}
	/**
	 * Links a callback into a label.
	 * @param name the name of the label.
	 * @param callback the callback you're going to add 
	 */
	public function addCallbackTo(name:String, callback:()->Void)
	{
		if (!frameLabels.exists(name))
		{
			FlxG.log.error('"$name" does not exist as a frame label! have misspelled it?');
			return;
		}

		var array:Array<()->Void> = (labelcallbacks.exists(name)) ? labelcallbacks.get(name) : [];

		array.push(callback);

		labelcallbacks.set(name, array);
	}

	public function removeCallbackFrom(label:String, callback:()->Void)
	{
		if (!labelcallbacks.exists(label))
		{
			FlxG.log.warn('There arent any callbacks set in label "$label"!');
			return;
		}
		var array = labelcallbacks.get(label);
		array.remove(callback);

		labelcallbacks.set(label, array);
	}

	public function removeAllCallbacksFrom(label:String)
	{
		if (!labelcallbacks.exists(label))
		{
			FlxG.log.warn('There arent any callbacks set in label "$label"!');
			return;
		}
		labelcallbacks.remove(label);
	}

	function getFrameLabels(TL:Timeline)
	{
		frameLabels = new Map();
		for (layer in TL.L)
		{
			var name:Null<String> = null;
			for (frame in layer.FR)
			{
				if (name != frame.N && frame.N != null)
				{
					if (name != null)
						labelArray.set(name, frame.N);
					name = frame.N;
					frameLabels.set(name, frame.I);
				}
			}
		}
	}
	
	public function getByName(name:String)
	{
		return animsMap.get(name);
	}
	override function destroy()
	{
		xFlip = yFlip = false;
		coolParse = null;
		frameLength = -1;
		curFrame = 0;
		frameLabels = null;
		labelArray = null;
		labelcallbacks = null;
		symbolName = null;
		framerate = 0;
		frameTick = 0;
		animsMap = null;
		callbackCalled = false;
		loopType = null;
		symbolType = null;
		curLabel = null;
		symbolDictionary = null;
		frames.destroy();
		super.destroy();
	}
}
