package flxanimate.animate;

import flixel.math.FlxMatrix;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flxanimate.data.AnimationData;
import openfl.Assets;

class FlxAnimate extends FlxTypedSpriteGroup<FlxSymbol>
{
	/**
	 * When ever the animation is playing.
	 */
	public var isPlaying(default, null):Bool = false;

	/**
	 * Internal, used for each skip between frames.
	 */
	@:noCompletion
	var frameTick:Float;

	/**
	 * Internal, used for each skip between frames.
	 */
	@:noCompletion
	var framerate:Float;

	public var curFrame(default, set):Int = 0;

	var loopType:LoopType = LOOP;
	var firstFrame:Int = 0;

	/**
	 * Internal, the frame that is being selected to draw
	 */
	var selectedFrame:Frame;

	/**
	 * Adds a Texture Atlas
	 * 
	 * @param X 			The initial X position of the Texture Sheet.
	 * @param Y 			The initial Y position of the Texture Sheet.
	 * @param Description 	The `Animation.json`.
	 * @param Framerate 	The initial framerate of the Texture Sheet.
	 */
	public function new(X:Float = 0, Y:Float = 0, Description:String, ?Framerate:Int = 0)
	{
		if (Assets.exists(Description))
			Description = Assets.getText(Description);

		var data:Parsed = haxe.Json.parse(Description);

		framerate = Framerate >= 0 ? data.MD.FRT : Framerate;

		super(X, Y);

		if (Reflect.hasField(data.AN, "STI"))
		{
			loopType = data.AN.STI.SI.LP;
		}
	}

	function renderFrame(layer:Layer, coolParsed:Parsed)
	{
		var frameStuff = AnimationData.parseDurationFrames(layer.FR);

		var newFrameNum:Int = 0;
		switch (loopType)
		{
			case LOOP:
				newFrameNum = curFrame % frameStuff.length;
			case PLAY_ONCE:
				newFrameNum = (curFrame >= frameStuff.length - 1) ? curFrame = frameStuff.length - 1 : curFrame;
			case SINGLE_FRAME:
				newFrameNum = firstFrame;
		}

		selectedFrame = frameStuff[newFrameNum];

		if (selectedFrame != null)
		{
			for (element in selectedFrame.E)
			{
				if (Reflect.hasField(element, 'SI'))
				{
					var nestedSymbol:FlxSymbol = new FlxSymbol(x, y);
					nestedSymbol.frames = frames;

					nestedSymbol.frame = nestedSymbol.frames.getByName(element.SI.SN);
					var symbolM:FlxMatrix = new FlxMatrix(element.SI.M3D[0], element.SI.M3D[1], element.SI.M3D[4], element.SI.M3D[5], element.SI.M3D[12],
						element.SI.M3D[13]);
					symbolM.concat(_matrix);
					nestedSymbol._matrix.concat(symbolM);

					/*nestedSymbol.firstFrame = element.SI.FF;
					nestedSymbol.loopType = element.SI.LP;*/

					nestedSymbol.matrixExposed = true;
					nestedSymbol.antialiasing = antialiasing;
					nestedSymbol.shader = shader;
					nestedSymbol.origin.set(element.SI.TRP.x, element.SI.TRP.y);
					nestedSymbol.scrollFactor.set(scrollFactor.x, scrollFactor.y);

					add(nestedSymbol);
				}
				else if (Reflect.hasField(element, 'ASI'))
				{
					var m3d = element.ASI.M3D;

					var atlasM:FlxMatrix = new FlxMatrix(m3d[0], m3d[1], m3d[4], m3d[5], m3d[12], m3d[13]);
					var spr:FlxSymbol = new FlxSymbol(x, y);
					spr.frames = frames;
					spr.frame = spr.frames.getByName(element.ASI.N);

					atlasM.concat(_matrix);
					spr.matrixExposed = true;
					spr.antialiasing = antialiasing;
					spr.shader = shader;
					spr.origin.set();
					spr.transformMatrix.concat(atlasM);
					origin.add(spr.x, spr.y);

					add(spr);
				}
			}
		}
	}

	function set_curFrame(value:Int):Int
	{
		return curFrame = value <= 0 ? curFrame : value;
	}

	public function playAnim(reverse:Bool = false)
	{
		isPlaying = true;
	}

	public function pauseAnim()
	{
		isPlaying = false;
	}

	public function stopAnim()
	{
		pauseAnim();
		curFrame = 0;
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (isPlaying)
		{
			frameTick += elapsed;

			if (frameTick >= 1 / framerate)
			{
				curFrame += 1;
				frameTick = 0;
			}
		}
	}
}
