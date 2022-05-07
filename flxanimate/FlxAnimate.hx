package flxanimate;

import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flxanimate.animate.FlxAnim.ButtonEvent;
import flxanimate.zip.Zip;
import openfl.Assets;
import haxe.io.BytesInput;
import haxe.zip.Reader;
import flixel.system.FlxSound;
import flixel.FlxG;
import flxanimate.data.AnimationData;
import flixel.FlxSprite;
import flxanimate.animate.FlxAnim;
import flxanimate.frames.FlxAnimateFrames;

typedef Settings = {
	?ButtonSettings:Map<String, flxanimate.animate.FlxAnim.ButtonSettings>,
	?FrameRate:Float,
	?Reversed:Bool,
	?OnComplete:Void->Void,
	?ShowPivot:Bool,
	?Antialiasing:Bool,
	?ScrollFactor:FlxPoint,
	?Offset:FlxPoint,
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
	public var audio:FlxSound;
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
		anim.frames = FlxAnimateFrames.fromTextureAtlas(Path);
		anim.setShit();
		setTheSettings(Settings);
	}

	public override function draw()
	{
		if (anim != null && anim.frames != null)
		{
			anim.offset = offset;
			anim.scale = scale;
			anim.scrollFactor = scrollFactor;
			anim.renderFrames(timeline);
		}
		super.draw();
	}
	override function set_flipX(Value:Bool)
	{
		anim.xFlip = Value;
		return super.set_flipX(Value);
	}
	override function set_flipY(Value:Bool)
	{
		anim.yFlip = Value;
		return super.set_flipY(Value);
	}
	override function set_x(Value:Float)
	{
		if (anim != null)
			anim.x = Value;
		return super.set_x(Value);
	}
	override function set_y(Value:Float)
	{
		if (anim != null)
			anim.y = Value;
		return super.set_y(Value);
	}
	override function set_cameras(Value:Array<FlxCamera>)
	{
		if (anim != null)
			anim.cameras = Value;
		return super.set_cameras(Value);
	}
	override function set_antialiasing(Value:Bool)
	{
		if (anim != null)
			anim.antialiasing = Value;
		return super.set_antialiasing(Value);
	}
	override function set_visible(Value:Bool)
	{
		if (anim != null)
			anim.visible = Value;
		return super.set_visible(Value);
	}
	override function checkEmptyFrame()
	{
		@:privateAccess
		if (showPivot || anim == null)
			loadGraphic("flxanimate/images/pivot.png");
	}
	override function destroy()
	{
		anim.destroy();
		anim = null;
		timeline = null;
		onClick = null;
		onComplete = null;
		framerate = 0;
		reversed = showPivot = isPlaying = false;
		#if FLX_SOUND_SYSTEM
		if (audio != null)
			audio.destroy();
		#end
		super.destroy();
	}
	public function playAnim(?Name:String, Force:Bool = false, Reverse:Bool = false, Frame:Int = 0)
	{
		pauseAnim();
		@:privateAccess
		var curThing = anim.animsMap.get(Name);
		@:privateAccess
		if (curThing != null && anim.name != Name || Force || !Reverse && anim.curFrame >= anim.length || Reverse && anim.curFrame <= 0)
		{
			if (!Reverse)
				anim.curFrame = Frame;
			else
				anim.curFrame =  Frame - anim.length;
		}
		@:privateAccess
		if ([null, ""].indexOf(Name) == -1 && curThing != null)
		{
			anim.x = x + curThing.X;
			anim.y = y + curThing.Y;
			anim.frameLength = 0;
			for (layer in curThing.timeline.L)
			{
				if (anim.frameLength < layer.FR.length)
				{
					anim.frameLength = layer.FR.length;
				}
			}
			timeline = curThing.timeline;
			@:privateAccess
			anim.loopType = curThing.looped ? loop : playonce;
			@:privateAccess
			anim.name = curThing.symbolName;
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
	override function set_alpha(Alpha:Float)
	{
		anim.alpha = Alpha;
		return super.set_alpha(Alpha);
	}
	override function set_color(Value:flixel.util.FlxColor)
	{
		anim.color = Value;
		return super.set_color(Value);
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!isPlaying)
			return;
		
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
	public function setButtonPack(button:String, callbacks:ClickStuff #if FLX_SOUND_SYSTEM , sound:FlxSound #end)
	{
		@:privateAccess
		anim.buttonMap.set(button, {Callbacks: callbacks, #if FLX_SOUND_SYSTEM Sound:  sound #end});
	}
	function setTheSettings(?Settings:Settings)
	{
		framerate = anim.coolParse.MD.FRT;
		@:privateAccess
		if (Settings != null)
		{
			if (Settings.ButtonSettings != null)
			{
				anim.buttonMap = Settings.ButtonSettings;
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
			if (Settings.ScrollFactor != null)
				scrollFactor = Settings.ScrollFactor;
			if (Settings.Offset != null)
				offset = Settings.Offset;
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
					continue;
				}
			}
			@:privateAccess
			FlxAnimateFrames.zip = thing;
		}
		else
		{
			jsontxt = haxe.Json.parse(openfl.Assets.getText('$Path/Animation.json'));
		}

		return jsontxt;
	}
}
