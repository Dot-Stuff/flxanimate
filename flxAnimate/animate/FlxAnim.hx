package flxAnimate.animate;

import openfl.geom.Point;
import openfl.filters.BlurFilter;
import openfl.display.BlendMode;
import flixel.group.FlxSpriteGroup;
import lime.math.Vector4;
import openfl.display.Bitmap;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flxAnimate.data.AnimationData;

class FlxAnim extends FlxSprite
{
	public var coolParse:Parsed;
	public var firstFrame:Int = 0;
	var swagFrame:Frame;

	public var daLoopType:LoopType = LOOP;

	/**
	 * Add a new texture atlas sprite
	 * @param x the X axis
	 * @param y the Y axis
	 * @param coolParsed The Animation.json file
	 * @param frame Which frame do you want to begin with, the default one is 0
	 */
	public function new(x:Float, y:Float, coolParsed:Parsed, frame:Int = 0)
	{
		super(x, y);
		this.coolParse = coolParsed;
		curFrame = frame;
		
		if (Reflect.hasField(coolParsed.AN, "STI"))
		{
			daLoopType = AnimationData.parseLoopType(coolParsed.AN.STI.SI.LP);
		}
		var hasSymbolDictionary:Bool = Reflect.hasField(coolParse, "SD");
		if (hasSymbolDictionary)
		{
			symbolAtlasShit = parseSymbolDictionary(coolParse);
		}
	}

	public var symbolAtlasShit:Map<String, String> = new Map();
	
	public var transformMatrix:FlxMatrix = new FlxMatrix();

	function renderFrame(TL:Timeline, coolParsed:Parsed, ?traceShit:Bool = false)
	{
		for (layer in TL.L)
		{
			var frameStuff = AnimationData.parseDurationFrames(layer.FR);
			if (FlxG.keys.justPressed.TWO)
				trace(layer.LN);
			
			var newFrameNum:Int = 0;
			switch (daLoopType)
			{
				case LOOP, null:
					newFrameNum = curFrame % frameStuff.length;
				case PLAY_ONCE:
					newFrameNum = (curFrame >= frameStuff.length - 1) ? curFrame = frameStuff.length - 1 : curFrame;
				case SINGLE_FRAME:
					newFrameNum = firstFrame;
			}
			
			swagFrame = frameStuff[newFrameNum];
			
			for (element in swagFrame.E)
			{
				if (Reflect.hasField(element, 'SI'))
				{
					var nestedSymbol = symbolMap.get(element.SI.SN);
					var nestedShit:FlxAnim = new FlxAnim(x, y, coolParse);
					if (FlxG.keys.justPressed.SIX)
						trace(layer.LN + " [" + nestedShit.x + "," + nestedShit.y + "]");
					nestedShit.frames = frames;

					nestedShit.frame = nestedShit.frames.getByName(element.SI.SN);
					var symbolM:FlxMatrix = new FlxMatrix(element.SI.M3D[0], element.SI.M3D[1], element.SI.M3D[4], element.SI.M3D[5], element.SI.M3D[12], element.SI.M3D[13]);
					symbolM.concat(_matrix);
					nestedShit._matrix.concat(symbolM);
					if (FlxG.keys.justPressed.ONE)
					{
						trace("SI - " + layer.LN + ": " + element.SI.SN + " - LO");
					}

					nestedShit.firstFrame = element.SI.FF;
					nestedShit.daLoopType = AnimationData.parseLoopType(element.SI.LP);
					nestedShit.matrixExposed = true;
					nestedShit.origin.set(element.SI.TRP.x, element.SI.TRP.y);
					nestedShit.scrollFactor.set(scrollFactor.x, scrollFactor.y);
					
					nestedShit.curFrame = newFrameNum;
					if (FlxG.keys.justPressed.FOUR)
						trace('Layer ${layer.LN} frame: ${nestedShit.curFrame}');
					if (FlxG.keys.justPressed.FIVE)
						trace('Layer ${layer.LN} duration: ${swagFrame.DU}, frameLength: ${frameStuff.length}');
					nestedShit.renderFrame(nestedSymbol, coolParsed);
				}
				else if (Reflect.hasField(element, 'ASI'))
				{
					var m3d = element.ASI.M3D;
					
					var atlasM:FlxMatrix = new FlxMatrix(m3d[0], m3d[1], m3d[4], m3d[5], m3d[12], m3d[13]);
					var spr:FlxAnim = new FlxAnim(x, y, coolParsed);
					matrixExposed = true;
					spr.frames = frames;
					spr.frame = spr.frames.getByName(element.ASI.N);

					if (FlxG.keys.justPressed.SEVEN)
					{
						trace("name frames: " + spr.frame.name);
					}
					
					atlasM.concat(_matrix);
					spr.matrixExposed = true;
					spr.antialiasing = true;
					spr.origin.set();
					spr.transformMatrix.concat(atlasM);
					origin.add(spr.x, spr.y);

					spr.curFrame = newFrameNum;
					spr.draw();
					if (FlxG.keys.justPressed.ONE)
					{
						trace("ASI - " + layer.LN + ": " + element.ASI.N);
					}
				}
			}
		}
	}

	var symbolMap:Map<String, Timeline> = new Map();
	
	function parseSymbolDictionary(coolParsed:Parsed):Map<String, String>
	{
		var awesomeMap:Map<String, String> = new Map();
		for (symbol in coolParsed.SD.S)
		{
			if (symbol.SN != null)
			{
				symbolMap.set(symbol.SN, symbol.TL);
				var symbolName = symbol.SN;
				// on time reverse?
				
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

	override function drawComplex(camera:FlxCamera):Void
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
		
		_matrix.translate(_point.x, _point.y);
		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}

	public var curFrame(default, set):Int;
	public var matrixExposed:Bool;

	public function renderFrames()
	{
		renderFrame(coolParse.AN.TL, coolParse);
	}
	
	function set_curFrame(value:Int):Int
	{
		return Std.int(Math.abs(value));
	}
	
}
