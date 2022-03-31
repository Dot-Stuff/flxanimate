package flxanimate.animate;

import flixel.FlxBasic;
import flixel.tweens.FlxTween;
import openfl.geom.ColorTransform;
import openfl.filters.GlowFilter;
import flixel.graphics.frames.FlxFilterFrames;
import openfl.filters.BlurFilter;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMatrix;
import flxanimate.data.AnimationData;
import flixel.system.FlxSound;
import flixel.graphics.frames.FlxFrame;

typedef SymbolStuff = {var timeline:Timeline; var X:Float; var Y:Float; var frameRate:Float;};
class FlxAnim extends FlxSprite
{
	public var xFlip(default, set):Bool;
	public var yFlip(default, set):Bool;
	public var coolParse(default, null):AnimAtlas;
	public var length(get, never):Int;
	var frameLabels:Map<String, Int> = new Map();
	var labelArray:Map<String, String> = new Map();
	var labelcallbacks:Map<String, Array<()->Void>> = new Map();
	public var clickedButton:Bool = false;
	
	var optimisedDrawing = true;

	var name:String;

	public var curFrame:Int = 0;

	var animsMap:Map<String, SymbolStuff> = new Map();

	var colorEffect:ColorTransform;
	
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

	function renderSymbol(TL:Timeline)
	{
		for (layer in TL.L)
		{
			if ([button, "button"].indexOf(symbolType) != -1)
			{
				setButtonFrames();
			}
			
			if (curFrame < 0)
			{
				if ([loop, "loop"].indexOf(loopType) != -1)
					curFrame += (length > 0) ? length : curFrame;
				else
					curFrame = 0;
			}
			if (curFrame >= length)
			{
				if ([loop, "loop"].indexOf(loopType) != -1)
				{
					curFrame -= (length > 0) ? length : curFrame;
				}
				else
				{
					curFrame = length;
				}
			}

			var selectedFrame = layer.FR[curFrame];
			curLabel = selectedFrame.N;
			if (selectedFrame != null)
			{
				for (element in selectedFrame.E)
				{
					// Is this a symbol?
					if (element.SI != null)
					{
						var m3d = element.SI.M3D;
						var timeline = symbolDictionary.get(element.SI.SN);
						var matrix:FlxMatrix = new FlxMatrix(m3d[0], m3d[1], m3d[4], m3d[5], m3d[12], m3d[13]);
						matrix.concat(_matrix);
						var symbol:FlxLimb = new FlxLimb(matrix.tx + x, matrix.ty + y, this);
						symbol.colorEffect = new ColorTransform();
						symbol.colorEffect.concat(colorEffect);
						symbol.symbolDictionary = symbolDictionary;
						symbol.frames = frames;
						if (element.SI.bitmap == null)
							symbol.frameLength = setSymbolLength(timeline);
						matrix.tx = matrix.ty = 0;
						symbol._matrix.concat(matrix);
						symbol.symbolType = element.SI.ST;
						symbol.name = element.SI.SN;

						if (["G", "graphic"].indexOf(symbol.symbolType) != -1)
						{symbol.curFrame = element.SI.FF; symbol.loopType = element.SI.LP;}
						else
							symbol.loopType = singleframe;
						if (element.SI.C != null)
						{
							symbol.addColorEffect(element.SI.C);
						}
						if (element.SI.bitmap == null)
							symbol.renderSymbol(timeline);
						else
						{
							symbol.frame = frames.getByName(element.SI.bitmap.N);
							symbol.draw();
						}
					}
					else if (element.ASI != null) // It's a drawing?
					{
						var m3d = element.ASI.M3D;
						var matrix:FlxMatrix = new FlxMatrix(m3d[0], m3d[1], m3d[4], m3d[5], m3d[12], m3d[13]);
						matrix.concat(_matrix);
						var spr:FlxLimb = new FlxLimb(matrix.tx + x, matrix.ty + y,this);
						matrix.tx = matrix.ty = 0;
						spr.frame = frames.getByName(element.ASI.N);
						spr._matrix.concat(matrix);
						spr.colorTransform.concat(colorEffect);
						spr.draw();
					}
				}
			}
		}
	}

	public var symbolDictionary:Map<String, Timeline> = new Map<String, Timeline>();
	function addColorEffect(sInstance:ColorEffects)
	{
		var CT = new ColorTransform();
		switch (sInstance.M)
		{
			case Tint, "Tint":
			{
				var color = FlxColor.fromString(sInstance.TC);
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
		
		colorEffect.concat(CT);
	}
	public function setButtonFrames()
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
			if (FlxG.mouse.justPressed)
				clickedButton = true;
			if (FlxG.mouse.pressed)
			{
				curFrame = 2;
			}
			else
			{
				curFrame = 1;
			}
		}
		else
		{
			curFrame = 0;
		}
	}

	public function renderFrames(timeline:Timeline)
	{
		renderSymbol(timeline);
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
		colorEffect = new ColorTransform();
		reverseLayers();
		setSymbols(coolParse);
		getFrameLabels(coolParse.AN.TL);
		if (coolParse.AN.STI != null)
		{
			loopType = coolParse.AN.STI.SI.LP;
			symbolType = coolParse.AN.STI.SI.ST;
			if (coolParse.AN.STI.SI.C != null)
			{
				addColorEffect(coolParse.AN.STI.SI.C);
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
		}
		else
		{
			_matrix.a = oldMatrix.a;
			_matrix.c = oldMatrix.c;
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
		}
		else
		{
			_matrix.b = oldMatrix.b;
			_matrix.d = oldMatrix.d;
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
		return length;
	}
	/**
	 * Creates an animation using an already made symbol from a texture atlas
	 * @param Name The name of the animation
	 * @param SymbolName the name of the symbol you're looking.
	 * @param X the *x* axis of the animation.
	 * @param Y  the *y* axis of the animation.
	 * @param FrameRate the framerate of the animation.
	 */
	public function addBySymbol(Name:String, SymbolName:String, X:Float = 0, Y:Float = 0, FrameRate:Float = 30)
	{
		var timeline:Timeline = symbolDictionary.get(SymbolName);
		if (timeline != null)
			animsMap.set(Name, {timeline: timeline, X: X, Y: Y, frameRate: FrameRate});
		else
			FlxG.log.error('No symbol was found with the name $SymbolName!');
	}
	/**
	 * Creates an animation using the indices, looking as a reference the main animation of the texture atlas.
	 * @param Name The name of the animation you're creating
	 * @param Indices The indices you're gonna be using for the animation, like `[0,1,2]`.
	 * @param FrameRate the framerate of the animation.
	 */
	public function addByAnimIndices(Name:String, Indices:Array<Int>, FrameRate:Float = 30) 
	{
		var layers:Array<Layers> = [];
		for (layer in coolParse.AN.TL.L)
		{
			var frames:Array<Frame> = [];
			for (i in Indices)
			{
				if (i > frameLength)
					FlxG.log.error('The index exceeds the length of the anim, which is $frameLength!');
				else
					frames.push(layer.FR[i]);
			}
			layers.push({LN: layer.LN, FR: frames});
		}

		animsMap.set(Name, {timeline: {L: layers}, X: 0, Y: 0, frameRate: FrameRate});
	}

	public function get_length()
	{
		return frameLength - 1;
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

	public function goToFrameLabel(name:String)
	{
		var framenum = getFrameLabel(name);

		if (framenum != null)
			curFrame = framenum;
	}

	public function getNextToFrameLabel(name:String):Null<String>
	{
		var thing = labelArray.get(name);
		if (thing == null)
			FlxG.log.error('Frame label $name does not exist! Maybe you mispelled it?');
		return thing;
	}

	public function addCallbackTo(label:String, callback:()->Void)
	{
		if (!frameLabels.exists(label))
		{
			FlxG.log.error('"$label" does not exist as a frame label! have misspelled it?');
			return;
		}

		var array:Array<()->Void> = (labelcallbacks.exists(label)) ? labelcallbacks.get(label) : [];

		array.push(callback);

		labelcallbacks.set(label, array);
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
	override function destroy()
	{
		xFlip = yFlip = false;
		coolParse = null;
		frameLength = 1;
		curFrame = 0;
		frameLabels = null;
		labelArray = null;
		labelcallbacks = null;
		name = null;
		animsMap = null;
		callbackCalled = false;
		colorEffect = null;
		loopType = null;
		symbolType = null;
		curLabel = null;
		super.destroy();
	}
	override public function draw():Void
	{
		if (alpha == 0)
			return;

		if (dirty) // rarely
			calcFrame(useFramePixels);

		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || optimisedDrawing && !isOnScreen(camera))
				continue;

			getScreenPosition(_point, camera).subtractPoint(offset);

			if (isSimpleRender(camera))
				drawSimple(camera);
			else
				drawComplex(camera);

			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}
}
@:noCompletion
class FlxLimb extends FlxAnim
{
	public function new(X:Float, Y:Float,Settings:FlxAnim) 
	{
		super(X, Y, null);
		antialiasing = Settings.antialiasing;
		offset = Settings.offset;
		xFlip = Settings.xFlip;
		yFlip = Settings.yFlip;
		scrollFactor = Settings.scrollFactor;
		optimisedDrawing = Settings.optimisedDrawing;
	}

	public override function drawComplex(camera:FlxCamera):Void
	{
		_matrix.concat(_frame.prepareMatrix(new FlxMatrix()));
		_matrix.scale(scale.x, scale.y);
		if (bakedRotationAngle <= 0)
		{
			updateTrig();
			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}
		if (isPixelPerfectRender(camera))
		{
			_point.floor();
		}

		_matrix.translate(_point.x, _point.y);
		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}
}
class ButtonEvent
{
	/**
	 * The callback function to call when this even fires.
	 */
	public var callback:Void->Void;

	#if FLX_SOUND_SYSTEM
	/**
	 * The sound to play when this event fires.
	 */
	public var sound:FlxSound;
	#end

	/**
	 * @param   Callback   The callback function to call when this even fires.
	 * @param   sound      The sound to play when this event fires.
	 */
	public function new(?Callback:Void->Void, ?sound:FlxSound)
	{
		callback = Callback;

		#if FLX_SOUND_SYSTEM
		this.sound = sound;
		#end
	}

	/**
	 * Cleans up memory.
	 */
	public inline function destroy():Void
	{
		callback = null;

		#if FLX_SOUND_SYSTEM
		sound.destroy();
		#end
	}

	/**
	 * Fires this event (calls the callback and plays the sound)
	 */
	public inline function fire():Void
	{
		if (callback != null)
			callback();

		#if FLX_SOUND_SYSTEM
		if (sound != null)
			sound.play(true);
		#end
	}
}
