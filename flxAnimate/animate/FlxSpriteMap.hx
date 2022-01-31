package flxanimate.animate;

import flixel.FlxSprite;

class FlxSpriteMap extends FlxSprite
{
	/**
	 * When ever the animation is playing.
	 */
	public var isPlaying(default, null):Bool = false;

	public var anim(default, null):FlxAnim;

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

	/**
	 * Creates a `FlxSpriteMap` at specified position.
	 * 
	 * @param X 		The initial X position of the texture sheet.
	 * @param Y 		The initial Y position of the texture sheet.
	 * @param Path 		
	 * @param Framerate The initial framerate of the texture sheet.
	 */
	public function new(?X:Float = 0, ?Y:Float = 0, Path:String, ?Framerate:Int = 0)
	{
		var jsontxt = haxe.Json.parse(openfl.Assets.getText('$Path/Animation.json'));
		anim = new FlxAnim(X, Y, jsontxt);

		// TODO: Move into FlxAnim
		anim.coolParse.AN.TL.L.reverse();

		if (Reflect.hasField(anim.coolParse, "SD"))
		{
			for (e in anim.coolParse.SD.S)
			{
				e.TL.L.reverse();
			}
		}

		framerate = Framerate >= 0 ? anim.coolParse.MD.FRT : Framerate;

		super(X, Y);

		anim.frames = FlxAnimateFrames.fromAnimate('$Path/spritemap1.png', '$Path/spritemap1.json');

		setEmptyBackground();
	}

	public function setEmptyBackground()
	{
		var orgWidth = width;
		var orgHeight = height;

		makeGraphic(1, 1, 0);
		width = orgWidth;
		height = orgHeight;
	}

	public override function draw()
	{
		super.draw();

		if (anim != null)
		{
			anim.visible = visible;
			anim.shader = shader;
			anim.antialiasing = antialiasing;
			anim.cameras = cameras;
			anim.x = x;
			anim.y = y;
			anim.scrollFactor.x = scrollFactor.x;
			anim.scrollFactor.y = scrollFactor.y;
			scrollFactor.putWeak();
			anim.renderFrames();
		}
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
		anim.curFrame = 0;
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (isPlaying)
		{
			frameTick += elapsed;

			if (frameTick >= 1 / framerate)
			{
				anim.curFrame += 1;
				frameTick = 0;
			}
		}
	}
}
