package flxanimate.animate;

import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMatrix;
import flxanimate.data.AnimationData;
import flixel.system.FlxSound;
import flixel.graphics.frames.FlxFrame;


typedef Effects = {var C:ColorEffects;};
typedef SymbolStuff = {var timeline:Timeline; var X:Float; var Y:Float; var frameRate:Float;};
class FlxAnim extends FlxSprite
{
	public var xFlip(default, set):Bool;
	public var yFlip(default, set):Bool;
	public var coolParse(default, null):AnimAtlas;
	public var animLength(get, never):Int;

	var name:String;

	public var OnClick:Void->Void;

	public var Sound:FlxSound;

	public var curFrame(default, set):Int;

	var animsMap:Map<String, SymbolStuff> = new Map();

	var colorEffect:Array<ColorEffects>;

	/**
	 * Internal, the parsed loop type
	 */
	var loopType(default, null):LoopType = loop;

	public var symbolType:SymbolType = "G";
	
	var frameLength:Int = 0;
	
	var symbolNested:Bool;

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
			if ([singleframe, "singleframe"].indexOf(loopType) == -1)
			{
				if (curFrame < 0)
				{
					curFrame = frameLength - 1;
				}
				if (curFrame >= frameLength)
				{
					if ([loop, "loop"].indexOf(loopType) != -1)
					{
						curFrame = 0;
					}
				}
			}
			var selectedFrame = layer.FR[curFrame];
			
			if (selectedFrame != null)
			{
				for (element in selectedFrame.E)
				{
					// Is this a symbol?
					if (element.SI != null)
					{
						var timeline = symbolDictionary.get(element.SI.SN);
						var m3d = (element.SI.M3D is Array) ? element.SI.M3D : [element.SI.M3D.m00, element.SI.M3D.m01, 
							element.SI.M3D.m02, element.SI.M3D.m03, element.SI.M3D.m10,element.SI.M3D.m11,
							element.SI.M3D.m12,element.SI.M3D.m13,element.SI.M3D.m20,element.SI.M3D.m21,element.SI.M3D.m22,
							element.SI.M3D.m23,element.SI.M3D.m30,element.SI.M3D.m31,element.SI.M3D.m32,element.SI.M3D.m33];
						if (element.SI.bitmap != null)
						{
							m3d[12] += element.SI.bitmap.POS.x;
							m3d[13] += element.SI.bitmap.POS.y;
						}
						var matrix:FlxMatrix = new FlxMatrix(m3d[0], m3d[1], m3d[4], m3d[5], m3d[12], m3d[13]);
						matrix.concat(_matrix);
						var symbol:FlxLimb = new FlxLimb(matrix.tx + x, matrix.ty + y, this);
						symbol.colorEffect = colorEffect;
						symbol.symbolDictionary = symbolDictionary;
						symbol.frameLength = setSymbolLength(timeline);
						matrix.tx = matrix.ty = 0;
						symbol._matrix.concat(matrix);
						if (element.SI.ST != null)
						{
							symbol.symbolType = element.SI.ST;
						}

						switch (symbol.symbolType)
						{
							case "G", "graphic":
								symbol.curFrame = element.SI.FF;
								symbol.loopType = element.SI.LP;
							case movieclip, "movieclip", "button", button:
								symbol.loopType = singleframe;
						}
						
						symbol.symbolNested = true;
						if ([button, "button"].indexOf(symbolType) != -1)
						{
							symbol.curFrame = curFrame;
						}
						if (element.SI.C != null)
						{
							if (symbol.colorEffect == null)
							{
								symbol.colorEffect = [element.SI.C];
							}
							else
							{
								symbol.colorEffect.push(element.SI.C);
							}
						}
						if (element.SI.bitmap == null)
							symbol.renderSymbol(timeline);
						else
						{
							symbol.frame = frames.getByName(element.SI.bitmap.N);
							symbol.transformMatrix.concat(matrix);
							symbol.draw();
						}
					}
					else if (element.ASI != null) // It's a drawing?
					{
						var m3d = (element.ASI.M3D != null) ? (element.ASI.M3D is Array) ? element.ASI.M3D : [element.ASI.M3D.m00, element.ASI.M3D.m01, 
							element.ASI.M3D.m02, element.ASI.M3D.m03, element.ASI.M3D.m10,element.ASI.M3D.m11,
							element.ASI.M3D.m12,element.ASI.M3D.m13,element.ASI.M3D.m20,element.ASI.M3D.m21,element.ASI.M3D.m22,
							element.ASI.M3D.m23,element.ASI.M3D.m30,element.ASI.M3D.m31,element.ASI.M3D.m32,element.ASI.M3D.m33] : [1.0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1];
						
						if (element.ASI.POS != null)
						{
							m3d[12] += element.ASI.POS.x;
							m3d[13] += element.ASI.POS.y;
						}
						var matrix:FlxMatrix = new FlxMatrix(m3d[0], m3d[1], m3d[4], m3d[5], m3d[12], m3d[13]);

						matrix.concat(_matrix);
						var spr:FlxLimb = new FlxLimb(matrix.tx + x, matrix.ty + y,this);

						spr.frame = spr.frames.getByName(element.ASI.N);
						spr.setSize(width, height);
						if (FlxG.keys.justPressed.W)
						{
							trace(width, height, spr.width, spr.height);
						}
						matrix.tx = matrix.ty = 0;
						spr.transformMatrix.concat(matrix);
						// TODO: Remodel this shit
						if (colorEffect != null)
						{
							var sInstance = colorEffect[0];
							final CT = spr.colorTransform;
							switch (sInstance.M)
							{
								case Tint:
								{
									var color = FlxColor.fromString(sInstance.TC);
									var opacity = sInstance.TM;
									CT.redMultiplier -= opacity;
									CT.redOffset = Math.round(color.red * (opacity - 0.01));
									CT.greenMultiplier -= opacity;
									CT.greenOffset = Math.round(color.green * (opacity - 0.01));
									CT.blueMultiplier -= opacity;
									CT.blueOffset = Math.round(color.blue * (opacity - 0.01));
								}
								case Alpha, "Alpha":
								{
									CT.alphaMultiplier = sInstance.AM;
								}
								case Brightness:
								{
									CT.redMultiplier = CT.greenMultiplier = CT.blueMultiplier -= Math.abs(sInstance.BRT);
									if (sInstance.BRT >= 0)
									{
										CT.redOffset = CT.greenOffset = CT.blueOffset = 255 * sInstance.BRT;
									}
								}
								case Advanced:
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
						}
						spr.draw();
					}
				}
			}
		}
	}

	public var symbolDictionary:Map<String, Timeline> = new Map<String, Timeline>();

	function setSymbolStuff(coolParsed:AnimAtlas)
	{
		var amazingMap:Map<String, SymbolInstance> = new Map();
		if (coolParsed.SD != null)
		{
			for (s in coolParsed.SD.S)
			{
				for (layer in s.TL.L)
				{
					var symbol:SymbolInstance = null;
					for (frame in layer.FR)
					{
						for (element in frame.E)
						{
							if (element.SI != null)
								symbol = element.SI;
							if (element.ASI != null)
							{
								amazingMap.set(element.ASI.N, symbol);
							}
						}
					}
				}
			}
		}
		if (coolParsed.AN.STI != null)
		{
			var symbol:SymbolInstance = null;
			for (layer in coolParsed.AN.TL.L)
			{
				for (frame in layer.FR)
				{
					for (element in frame.E)
					{
						symbol = coolParsed.AN.STI.SI;
						if (element.ASI != null)
						{
							amazingMap.set(element.ASI.N, symbol);
						}
					}
				}
			}
		}
		
		for (layer in coolParsed.AN.TL.L)
		{
			var symbol:SymbolInstance = null;
			for (frame in layer.FR)
			{
				for (element in frame.E)
				{
					if (element.SI != null)
						symbol = element.SI;
					if (element.ASI != null)
					{
						amazingMap.set(element.ASI.N, symbol);
					}
				}
			}
		}
		return amazingMap;
	}
	public function setButtonFrames(sprite:FlxAnim, badPress:Bool)
	{
		if (FlxG.mouse.overlaps(sprite) && !badPress)
		{
			if (FlxG.mouse.justPressed)
				new ButtonEvent(OnClick, Sound).fire();
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

	@:noCompletion
	function set_curFrame(value:Int):Int
	{
		return curFrame = value;
	}

	public function setLayers()
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
		symbolDictionary.set(Anim.AN.SN, Anim.AN.TL);
		if (coolParse.SD != null)
		{
			for (symbol in coolParse.SD.S)
			{
				for (layer in symbol.TL.L)
				{
					layer.FR = AnimationData.parseDurationFrames(layer.FR);
				}
				symbolDictionary.set(symbol.SN, symbol.TL);
			}
		}	
	}
	public function setShit()
	{
		setSymbols(coolParse);
		if (coolParse.AN.STI != null)
		{
			loopType = coolParse.AN.STI.SI.LP;
			symbolType = coolParse.AN.STI.SI.ST;
			if (coolParse.AN.STI.SI.C != null)
			{
				colorEffect = [coolParse.AN.STI.SI.C];
			}
		}
		for (layer in coolParse.AN.TL.L)
		{
			layer.FR = AnimationData.parseDurationFrames(layer.FR);
		}
		frameLength = animLength;
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
	 * This adds the animation name by a symbol
	 * @param name The animation name.
	 * @param SymbolName The symbolName which has an animation.
	 */
	public function addBySymbol(Name:String, SymbolName:String, X:Float = 0, Y:Float = 0, FrameRate:Float = 30)
	{
		var timeline:Timeline = symbolDictionary.get(SymbolName);
		if (timeline != null)
			animsMap.set(Name, {timeline: timeline, X: X, Y: Y, frameRate: FrameRate});
		else
			FlxG.log.error('No symbol was found with the name $SymbolName!');
	}
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
	public function get_animLength()
	{
		var length:Int = 0;
		for (len in coolParse.AN.TL.L)
		{
			if (length < len.FR.length)
				length = len.FR.length;
		}
		return length;
	}
}
@:noCompletion
class FlxLimb extends FlxAnim
{
	public var transformMatrix:FlxMatrix = new FlxMatrix();
	public function new(X:Float, Y:Float,Settings:FlxAnim) 
	{
		super(X, Y, null);
		antialiasing = Settings.antialiasing;
		frames = Settings.frames;
		offset = Settings.offset;
		xFlip = Settings.xFlip;
		yFlip = Settings.yFlip;
		origin.set();
		scrollFactor = Settings.scrollFactor;
	}
	public override function drawComplex(camera:FlxCamera):Void
	{
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);
		_matrix.concat(transformMatrix);
		if (bakedRotationAngle <= 0)
		{
			updateTrig();
			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}
		_point.addPoint(origin);
		if (isPixelPerfectRender(camera))
		{
			_point.x = Math.floor(_point.x);
			_point.y = Math.floor(_point.y);
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
