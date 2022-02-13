package flxanimate.animate;

import openfl.geom.Point;
import openfl.filters.BlurFilter;
import openfl.display.BlendMode;
import flixel.group.FlxSpriteGroup;
import openfl.display.Bitmap;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flxanimate.data.AnimationData;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.system.FlxSound;

class FlxAnim extends FlxSprite
{
	public var coolParse(default, null):AnimAtlas;

	public var firstFrame(default, null):Int = 0;

	/**
	 * Internal, the frame that is being selected to draw
	 */
	var selectedFrame:Frame;

	/**
	 * Internal, the parsed loop type
	 */
	var loopType(default, null):LoopType = LOOP;

	public var symbolType:SymbolType = GRAPHIC;

	var length:Int = 0;

	var graphicset:Bool = false;

	/**
	 * Add a new texture atlas sprite
	 * 
	 * @param X 			the X axis
	 * @param Y 			the Y axis
	 * @param coolParsed 	The Animation.json file
	 * @param frame 		Which frame do you want to begin with, the default one is 0
	 */
	public function new(?X:Float, ?Y:Float, coolParsed:AnimAtlas, frame:Int = 0)
	{
		super(X, Y);

		coolParse = coolParsed;
		curFrame = frame;

		if (coolParse.AN.STI != null)
		{
			loopType = coolParse.AN.STI.SI.LP;
		}
		if (coolParse.SD != null)
		{
			symbolAtlas = parseSymbolDictionary(coolParse);
		}
		for (len in coolParsed.AN.TL.L)
		{
			if (length < AnimationData.parseDurationFrames(len.FR).length - 1)
				length = AnimationData.parseDurationFrames(len.FR).length - 1;
		}
	}

	public var symbolAtlas:Map<String, String> = new Map();

	public var transformMatrix:FlxMatrix = new FlxMatrix();

	function renderFrame(TL:Timeline, coolParsed:AnimAtlas)
	{
		for (layer in TL.L)
		{
			var frameStuff = AnimationData.parseDurationFrames(layer.FR);
			if (FlxG.keys.justPressed.TWO)
				trace('[FlxAnimate] ${layer.LN}');

			var frameLength = (symbolType == MOVIE_CLIP) ? length : frameStuff.length;
			switch (loopType)
			{
				case LOOP:
					newFrameNum = curFrame % frameLength;
				case PLAY_ONCE:
					curFrame = (curFrame >= length) ? length : curFrame;
				case SINGLE_FRAME:
					curFrame = firstFrame;
			}

			selectedFrame = frameStuff[curFrame];

			if (selectedFrame != null)
			{
				for (element in selectedFrame.E)
				{
					if (element.SI != null)
					{
						var nestedSymbol = symbolMap.get(element.SI.SN);
						var nestedShit:FlxAnim = new FlxAnim(x, y, coolParse);
						nestedShit.frames = frames;

						nestedShit.frame = nestedShit.frames.getByName(element.SI.SN);
						var symbolM:FlxMatrix = new FlxMatrix(element.SI.M3D[0], element.SI.M3D[1], element.SI.M3D[4], element.SI.M3D[5], element.SI.M3D[12],
							element.SI.M3D[13]);
						symbolM.concat(_matrix);
						nestedShit._matrix.concat(symbolM);

						switch (element.SI.ST)
						{
							case GRAPHIC:
								nestedShit.firstFrame = element.SI.FF;
								nestedShit.loopType = element.SI.LP;
							case MOVIE_CLIP:
								nestedShit.firstFrame = 0;
								nestedShit.loopType = SINGLE_FRAME;
							case BUTTON:
						}

						nestedShit.matrixExposed = true;
						nestedShit.antialiasing = antialiasing;
						nestedShit.shader = shader;
						nestedShit.origin.set(element.SI.TRP.x, element.SI.TRP.y);
						nestedShit.scrollFactor.set(scrollFactor.x, scrollFactor.y);

						nestedShit.curFrame = curFrame;
						nestedShit.renderFrame(nestedSymbol, coolParsed);
					}
					else if (element.ASI != null)
					{
						var m3d = element.ASI.M3D;

						var atlasM:FlxMatrix = new FlxMatrix(m3d[0], m3d[1], m3d[4], m3d[5], m3d[12], m3d[13]);
						var spr:FlxAnim = new FlxAnim(x, y, coolParsed);
						matrixExposed = true;
						spr.frames = frames;
						spr.frame = spr.frames.getByName(element.ASI.N);

						if (FlxG.keys.justPressed.SEVEN)
						{
							trace('[FlxAnimate] Name Frames: ${spr.frame.name}');
						}

						atlasM.concat(_matrix);
						spr.matrixExposed = true;
						spr.antialiasing = antialiasing;
						spr.shader = shader;
						spr.origin.set();
						spr.scrollFactor.set(scrollFactor.x, scrollFactor.y);
						spr.transformMatrix.concat(atlasM);
						origin.add(spr.x, spr.y);

						spr.curFrame = curFrame;
						spr.draw();
						if (FlxG.keys.justPressed.ONE)
						{
							trace('[FlxAnimate] ASI - ${layer.LN}: ${element.ASI.N}');
						}
					}
				}
			}
		}
	}

	var symbolMap:Map<String, Timeline> = new Map<String, Timeline>();

	function parseSymbolDictionary(coolParsed:AnimAtlas):Map<String, String>
	{
		var awesomeMap:Map<String, String> = new Map();
		for (symbol in coolParsed.SD.S)
		{
			if (symbol.SN != null)
			{
				symbolMap.set(symbol.SN, symbol.TL);
				var symbolName = symbol.SN;

				for (layer in symbol.TL.L)
				{
					for (frame in layer.FR)
					{
						for (element in frame.E)
						{
							if (Reflect.hasField(element, 'ASI'))
							{
								awesomeMap.set(symbolName, element.ASI.N);
							}
						}
					}
				}
			}
		}

		return awesomeMap;
	}

	public override function draw()
	{
		checkEmptyFrame();

		if (alpha == 0 || _frame.type == FlxFrameType.EMPTY)
			return;

		if (dirty) // rarely
			calcFrame(useFramePixels);

		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
				continue;

			getScreenPosition(_point, camera).subtractPoint(offset);

			drawComplex(camera);
		}
	}

	// Small wip, don't worry, be happy
	public function setButtonFrames(sprite:FlxAnim, badPress:Bool)
	{
		if (FlxG.mouse.overlaps(sprite) && !badPress)
		{
			if (FlxG.mouse.justPressed)
				new ButtonEvent(OnClick, Sound).fire();
			if (FlxG.mouse.pressed)
			{
				firstFrame = 2;
			}
			else
			{
				firstFrame = 1;
			}
		}
		else
		{
			firstFrame = 0;
		}
	}

	public override function drawComplex(camera:FlxCamera):Void
	{
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);
		if (matrixExposed)
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

		_point.putWeak();

		_matrix.translate(_point.x, _point.y);
		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}

	public var curFrame(default, set):Int;
	public var matrixExposed:Bool;

	public function renderFrames()
	{
		renderFrame(coolParse.AN.TL, coolParse);
	}

	@:noCompletion
	function set_curFrame(value:Int):Int
	{
		return curFrame = value <= 0 ? curFrame : value;
	}

	public function setLayers()
	{
		coolParse.AN.TL.L.reverse();

		if (Reflect.hasField(coolParse, "SD"))
		{
			for (e in coolParse.SD.S)
			{
				e.TL.L.reverse();
			}
		}
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
