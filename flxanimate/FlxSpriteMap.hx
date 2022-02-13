package flxanimate;

import flxanimate.animate.FlxAnim;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.FlxG;

typedef Settings =
{
	?ButtonSettings:ButtonSettings,
	?FrameRate:Float,
	?Reversed:Bool,
	?OnComplete:Void->Void,
}

typedef ButtonSettings =
{
	?OnClick:Void->Void,
	#if FLX_SOUND_SYSTEM
	?Sound:FlxSound
	#end
}

class FlxSpriteMap extends FlxSprite
{
	/**
	 * When ever the animation is playing.
	 */
	public var isPlaying(default, null):Bool = false;

	@:isVar
	public var curFrame(get, set):Int;

	/**
	 * Internal, the first frame of the `FlxSpriteMap`.
	 */
	var anim(default, null):FlxAnim;

	public var onClick:Void->Void;

	public var onComplete:Void->Void;

	public var reversed:Bool = false;
	
	public var sound:FlxSound;

	var badPress:Bool = false;

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
	public function new(?X:Float = 0, ?Y:Float = 0, Path:String, ?Framerate:Int = 0, ?Settings:Settings)
	{
		var jsontxt = haxe.Json.parse(openfl.Assets.getText('$Path/Animation.json'));
		anim = new FlxAnim(X, Y, jsontxt);
		anim.setLayers();
		setTheSettings(Settings);
		super();

		anim.frames = FlxAnimateFrames.fromAnimate(Path);
	}

	public override function draw()
	{
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
		reversed = reverse;
		@:privateAccess
		if (reversed)
		{
			if (anim.curFrame >= 0)
			{
				anim.curFrame = anim.length;
			}
		}
		else
		{
			if (anim.curFrame >= anim.length)
			{
				anim.curFrame = 0;
			}
		}
		isPlaying = true;
	}

	public function pauseAnim()
	{
		isPlaying = false;
	}

	public function stopAnim()
	{
		isPlaying = false;
		anim.curFrame = 0;
	}

	public override function update(elapsed:Float)
	{
		if (anim.symbolType == BUTTON)
		{
			if (FlxG.mouse.pressed && !FlxG.mouse.overlaps(anim) && !badPress)
			{
				badPress = true;
			}
			if (FlxG.mouse.released && badPress)
			{
				badPress = false;
			}
			@:privateAccess
			anim.setButtonFrames(anim, badPress);
		}
		else
		{
			@:privateAccess
			if (!isPlaying)
				return;
			else
			{
				frameTick += elapsed;

				while (frameTick > framerate)
				{
					if (reversed)
					{
						anim.curFrame--;
					}
					else
					{
						anim.curFrame++;
					}
					frameTick = 0;
				}
				if (reversed && anim.curFrame == 0 && anim.loopType == LOOP)
				{
					anim.curFrame = anim.length;
				}
			}
			@:privateAccess
			if (onComplete != null && isPlaying && anim.loopType == PLAY_ONCE)
			{
				if (reversed)
				{
					if (anim.curFrame <= 0)
					{
						onComplete();
						isPlaying = false;
					}
				}
				else
				{
					if (anim.curFrame >= anim.length)
					{
						onComplete();
						isPlaying = false;
					}
				}
			}
		}
		super.update(elapsed);
	}

	function get_curFrame():Int
	{
		return anim.curFrame;
	}

	function set_curFrame(value:Int):Int
	{
		anim.curFrame = value;
		return curFrame = value;
	}

	function setTheSettings(?Settings:Settings)
	{
		framerate = 1 / anim.coolParse.MD.FRT;
		if (Settings != null)
		{
			if (Settings.ButtonSettings != null)
			{
				if (Settings.ButtonSettings.OnClick != null)
				{
					onClick = Settings.ButtonSettings.OnClick;
				}
				#if FLX_SOUND_SYSTEM
				if (Settings.ButtonSettings.Sound != null)
				{
					sound = Settings.ButtonSettings.Sound;
				}
				#end
				anim.symbolType = BUTTON;
			}
			if (Settings.Reversed != null)
			{
				reversed = Settings.Reversed;
			}
			if (Settings.FrameRate != null)
			{
				framerate = 1 / (Settings.FrameRate > 0 ? anim.coolParse.MD.FRT : Settings.FrameRate);
			}
			if (Settings.OnComplete != null)
			{
				onComplete = Settings.OnComplete;
			}
		}
	}
}
