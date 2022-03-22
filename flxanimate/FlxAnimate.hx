package flxanimate;

import flxanimate.animate.FlxAnim.ButtonEvent;
import flxanimate.zip.Zip;
import openfl.Assets;
import haxe.io.BytesInput;
import haxe.zip.Reader;
import flixel.system.FlxSound;
import flixel.FlxG;
import flxanimate.data.AnimationData;
import flixel.FlxSprite;
import lime._internal.format.Deflate;
import flxanimate.animate.*;

typedef Settings = {
	?ButtonSettings:ButtonSettings,
	?FrameRate:Float,
	?Reversed:Bool,
	?OnComplete:Void->Void,
	?ShowPivot:Bool,
	?Antialiasing:Bool
}
typedef ButtonSettings = {
	?OnClick:Void->Void,
	#if FLX_SOUND_SYSTEM
	?Sound:FlxSound
	#end
}

class FlxAnimate extends FlxSprite
{
	/**
	 * When ever the animation is playing.
	 */
	public var isPlaying(default, null):Bool = false;

	public var anim(default, null):FlxAnim;
	
	public var onClick:Void->Void;

	public var onComplete:Void->Void;

	#if FLX_SOUND_SYSTEM
	public var sound:FlxSound;
	#end

	public var showPivot:Bool = false;

	var reversed:Bool = false;

	/**
	 * Internal, used for each skip between frames.
	 */
	@:noCompletion
	var frameTick:Float;


	public var framerate(default, set):Float;

	/**
	 * Internal, used for each skip between frames.
	 */
	var frameDelay:Float;

	var timeline:Timeline;
	/**
	 * Creates a `FlxSpriteMap` at specified position.
	 * 
	 * @param X 		The initial X position of the texture sheet.
	 * @param Y 		The initial Y position of the texture sheet.
	 * @param Path
	 * @param Framerate The initial framerate of the texture sheet.
	 */
	public function new(X:Float = 0, Y:Float = 0, Path:String, ?Settings:Settings)
	{
		super(X, Y);
		makeGraphic(16,16,0);
		
		if (!Assets.exists('$Path/Animation.json') && haxe.io.Path.extension(Path) != "zip")
		{
			FlxG.log.error('Animation file hasnt been found in Path $Path, Have you written the correct Path?');
			return;
		}
		var jsontxt:AnimAtlas = atlasSetting(Path);
		timeline = jsontxt.AN.TL;
		anim = new FlxAnim(X, Y, jsontxt);
		anim.frames = FlxSpriteMap.fromAnimate(Path);
		anim.setShit();
		setTheSettings(Settings);
	}

	public override function draw()
	{
		if (anim != null && anim.frames != null)
		{
			anim.visible = visible;
			anim.antialiasing = antialiasing;
			anim.cameras = cameras;
			anim.x = x;
			anim.y = y;
			anim.offset = offset;
			anim.scrollFactor = scrollFactor;
			anim.xFlip = flipX;
			anim.yFlip = flipY;
			anim.renderFrames(timeline);
		}
		super.draw();
	}
	override function checkEmptyFrame()
	{
		@:privateAccess
		if (showPivot || anim == null)
			super.checkEmptyFrame();
	}
	public function playAnim(?Name:String, ForceRestart:Bool = false, Looped:Bool = false, Reverse:Bool = false, flipX:Bool = false, flipY:Bool = false)
	{
		@:privateAccess
		var curThing = anim.animsMap.get(Name);
		@:privateAccess
		if (curThing != null && anim.name != Name || ForceRestart || !Reverse && anim.curFrame >= anim.length || Reverse && anim.curFrame <= 0)
		{
			if (!Reverse)
				anim.curFrame = 0;
			else
				anim.curFrame = anim.length;
		}
		@:privateAccess
		if ([null, ""].indexOf(Name) == -1 && curThing != null)
		{
			anim.x = x;
			anim.y = y;
			timeline = curThing.timeline;
			if (curThing != null)
			{
				anim.x += curThing.X;
				anim.y += curThing.Y;
			}
			anim.frameLength = 0;
			for (layer in curThing.timeline.L)
			{
				if (anim.frameLength < layer.FR.length)
				{
					anim.frameLength = layer.FR.length;
				}
			}
			anim.renderFrames(timeline);
			@:privateAccess
			anim.loopType = Looped ? loop : playonce;
		}
		reversed = Reverse;
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
	
	function set_framerate(value:Float):Float
	{
		frameDelay = 1 / value;
		return framerate = value;
	}
	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (anim == null || anim.frames == null)
			return;
		if (anim.clickedButton)
		{
			new ButtonEvent(onClick, sound).fire();
			anim.clickedButton = false;
		}
		@:privateAccess
		if (!isPlaying)
			return;
		else
		{
			frameTick += elapsed;

			while (frameTick > frameDelay)
			{
				if (reversed)
				{
					anim.curFrame--;
				}
				else
				{
					anim.curFrame++;
				}
				frameTick -= frameDelay;
			}
		}
		@:privateAccess
		if (anim.curLabel != null)
		{
			if (anim.labelcallbacks.exists(anim.curLabel))
			{
				for (callback in anim.labelcallbacks.get(anim.curLabel))
					callback();
			}
		}
		@:privateAccess
		if ([playonce, "playonce"].indexOf(anim.loopType) != -1)
		{
			if (reversed)
			{
				if (anim.curFrame <= 0)
				{
					if (onComplete != null)
						onComplete();
					isPlaying = false;
				}
			}
			else
			{
				if (anim.curFrame >= anim.length)
				{
					if (onComplete != null)
						onComplete();
					isPlaying = false;	
				}
			}
		}
	}

	function setTheSettings(?Settings:Settings)
	{
		framerate = anim.coolParse.MD.FRT;
		if (Settings != null)
		{
			if (Settings.ButtonSettings != null)
			{
				if (Settings.ButtonSettings.OnClick != null)
				{
					onClick = Settings.ButtonSettings.OnClick;
				}
				if (Settings.ButtonSettings.Sound != null)
				{
					sound = Settings.ButtonSettings.Sound;
				}
				if ([button, "button"].indexOf(anim.symbolType) == -1)
					anim.symbolType = button;
			}
			if (Settings.Reversed != null)
				reversed = Settings.Reversed;
			if (Settings.FrameRate != null)
				framerate = (Settings.FrameRate > 0 ? anim.coolParse.MD.FRT : Settings.FrameRate);
			if (Settings.OnComplete != null)
				onComplete = Settings.OnComplete;
			if (Settings.ShowPivot != null)
				showPivot = Settings.ShowPivot;
			if (Settings.Antialiasing != null)
				antialiasing = Settings.Antialiasing;
		}
	}
	function atlasSetting(Path:String):AnimAtlas
	{
		var jsontxt:AnimAtlas = null;
		if (haxe.io.Path.extension(Path) == "zip")
		{
			var thing = Zip.readZip(new BytesInput(Assets.getBytes(Path)));
			
			for (list in Zip.unzip(thing))
			{
				if (list.fileName.indexOf("Animation.json") != -1)
				{
					jsontxt = haxe.Json.parse(list.data.toString());
					thing.remove(list);
					break;
				}
			}
			@:privateAccess
			FlxSpriteMap.zip = thing;
		}
		else
		{
			jsontxt = haxe.Json.parse(openfl.Assets.getText('$Path/Animation.json'));
		}

		return jsontxt;
	}
}
