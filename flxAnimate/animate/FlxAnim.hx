package flxanimate.animate;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxMatrix;
import openfl.geom.Matrix;
import flxAnimate.data.AnimationData;

class FlxAnim extends FlxSprite
{
	public var coolParse:Parsed;
	public var oldMatrix:Array<Float> = [];

	public var firstFrame:Int = 0;

	public var daLoopType:LoopType = LOOP; // LP by default, is set below!!!

	public function new(x:Float, y:Float, coolParsed:Parsed)
	{
		super(x, y);

		this.coolParse = coolParsed;
		
		if (Reflect.hasField(coolParsed.AN, "STI"))
		{
			daLoopType = AnimationData.parseLoopType(coolParsed.AN.STI.SI.LP);
		}
		var hasSymbolDictionary:Bool = Reflect.hasField(coolParse, "SD");

		if (hasSymbolDictionary)
			symbolAtlasShit = parseSymbolDictionary(coolParse);
	}

	var symbolAtlasShit:Map<String, String> = new Map();

	public var transformMatrix:Matrix = new Matrix();

	function renderFrame(TL:Timeline, coolParsed:Parsed, ?traceShit:Bool = false)
	{
		for (layer in TL.L)
		{
			var frames = parseDurationFrames(layer.FR);
			if (FlxG.keys.justPressed.TWO)
				trace(layer.LN);

			var frameNum:Int = 0;

			switch (daLoopType)
			{
				case LOOP, null:
					frameNum = daFrame % frames.length;
				case PLAY_ONCE:
					frameNum = (daFrame >= frames.length - 1) ? daFrame = frames.length - 1 : daFrame;
				case SINGLE_FRAME:
					frameNum = firstFrame;
			}

			var swagFrame:Frame = frames[frameNum];

			for (element in swagFrame.E)
			{
				if (Reflect.hasField(element, 'ASI'))
				{
					var m3d = element.ASI.M3D;
					var dumbassMatrix:Matrix = new Matrix(m3d[0], m3d[1], m3d[4], m3d[5], m3d[12], m3d[13]);

					var spr:FlxAnim = new FlxAnim(x, y, coolParsed);
					matrixExposed = true;
					spr.frames = frames;
					spr.frame = spr.frames.getByName(element.ASI.N);

					dumbassMatrix.concat(_matrix);
					spr.matrixExposed = true;
					spr.transformMatrix.concat(dumbassMatrix);

					spr.origin.set();

					spr.antialiasing = true;
					spr.draw();

					if (FlxG.keys.justPressed.ONE)
					{
						trace("ASI - " + layer.LN + ": " + element.ASI.N);
					}
				}
				else if (Reflect.hasField(element, 'SI'))
				{
					var nestedSymbol = symbolMap.get(element.SI.SN);
					var nestedShit:FlxAnim = new FlxAnim(x, y, coolParse);
					nestedShit.frames = frames;

					var swagMatrix:FlxMatrix = new FlxMatrix(element.SI.M3D[0], element.SI.M3D[1], element.SI.M3D[4], element.SI.M3D[5], element.SI.M3D[12], element.SI.M3D[13]);

					swagMatrix.concat(_matrix);

					nestedShit._matrix.concat(swagMatrix);
					nestedShit.origin.set(element.SI.TRP.x, element.SI.TRP.y);

					if (FlxG.keys.justPressed.ONE)
					{
						trace("SI - " + layer.LN + ": " + element.SI.SN + " - LO");
					}

					nestedShit.firstFrame = element.SI.FF;

					nestedShit.daLoopType = element.SI.LP;
					nestedShit.frameNum = frameNum;
					nestedShit.scrollFactor.set(1, 1);
					nestedShit.renderFrame(nestedSymbol, coolParsed);
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

		return awesomeMap;
	}

	public var daFrame:Int;
	public var matrixExposed:Bool;

	public function changeFrame(frameChange:Int = 0):Void
	{
		if (!(daFrame == 0 && frameChange == -1))
			daFrame += frameChange;
	}

	@:noCompletion function parseDurationFrames(frame:Array<Frame>):Array<Frame>
	{
		var frames:Array<Frame> = [];
		for (frame in frame)
		{
			for (i in 0...frame.DU)
			{
				frames.push(frame);
			}
		}
		return frames;
	}
		
	override function drawComplex(camera:FlxCamera):Void
	{
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (matrixExposed)
			_matrix.concat(transformMatrix);
		else if (bakedRotationAngle <= 0)
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
