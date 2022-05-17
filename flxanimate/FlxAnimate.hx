package flxanimate;

import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flxanimate.animate.*;
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
	 * Creates a `FlxAnimate` at a specified position from Adobe Animate texture atlas files.
	 * 
	 * @param X 		The initial X position of the sprite.
	 * @param Y 		The initial Y position of the ssprite.
	 * @param Path      The path to the Animate CC texture atlas files.
	 * @param Settings  Optional settings for the animation (antialiasing, framerate, reversed, etc.).
	 */
	public function new(X:Float = 0, Y:Float = 0, Path:String, ?Settings:Settings)
	{
		super(X, Y);
		
		if (!Assets.exists('$Path/Animation.json') && haxe.io.Path.extension(Path) != "zip")
		{
			FlxG.log.error('Animation file not found in specified path: "$path", have you written the correct path?');
			return;
		}

		var jsontxt:AnimAtlas = atlasSetting(Path);
		anim = new FlxAnim(X, Y, jsontxt);
		anim.frames = FlxAnimateFrames.fromTextureAtlas(Path);
		anim.setShit();
		setTheSettings(Settings);
	}

	public override function draw():Void
	{
		if (anim != null && anim.frames != null)
		{
			anim.offset = offset;
			anim.scale = scale;
			anim.scrollFactor = scrollFactor;
			anim.render();
		}
		super.draw();
	}

	override function set_flipX(Value:Bool):Bool
	{
		if (anim == null) return false;
		anim.xFlip = Value;
		return super.set_flipX(Value);
	}

	override function set_flipY(Value:Bool):Bool
	{
		if (anim == null) return false;
		anim.yFlip = Value;
		return super.set_flipY(Value);
	}

	override function set_x(Value:Float):Float
	{
		if (anim == null) return 0.0;
		anim.x = Value;
		return super.set_x(Value);
	}

	override function set_y(Value:Float):Float
	{
		if (anim == null) return 0.0;
		anim.y = Value;
		return super.set_y(Value);
	}

	override function set_cameras(Value:Array<FlxCamera>):Array<FlxCamera>
	{
		if (anim == null) return [FlxG.camera];
		anim.cameras = Value;
		return super.set_cameras(Value);
	}

	override function set_antialiasing(Value:Bool):Bool
	{
		if (anim == null) return false;
		anim.antialiasing = Value;
		return super.set_antialiasing(Value);
	}

	override function set_visible(Value:Bool):Bool
	{
		if (anim == null) return true;
		anim.visible = Value;
		return super.set_visible(Value);
	}

	override function checkEmptyFrame():Void
	{
		@:privateAccess
		if (showPivot || anim == null)
			loadGraphic("flxanimate/images/pivot.png");
		else
			makeGraphic(16, 16, 0);
	}

	override function destroy():Void
	{
		anim.destroy();
		anim = null;
		onClick = null;
		onComplete = null;
		reversed = showPivot = isPlaying = false;
		#if FLX_SOUND_SYSTEM
		if (audio != null)
			audio.destroy();
		#end
		super.destroy();
	}

	override function set_alpha(Alpha:Float):Float
	{
		anim.alpha = Alpha;
		return super.set_alpha(Alpha);
	}

	override function set_color(Value:flixel.util.FlxColor):flixel.util.FlxColor
	{
		anim.color = Value;
		return super.set_color(Value);
	}

	public override function update(elapsed:Float):Void
	{
		#if debug
		if (FlxG.keys.pressed.H)
			AnimationData.filters.hue = (AnimationData.filters.hue + 2) % 360;
		if (FlxG.keys.pressed.S)
			AnimationData.filters.saturation = (AnimationData.filters.saturation + 2) % 100;
		if (FlxG.keys.anyPressed([V, B]))
			AnimationData.filters.brightness = (AnimationData.filters.brightness + 2);
		#end
		super.update(elapsed);
		anim.update(elapsed);
	}

	public function setButtonPack(button:String, callbacks:ClickStuff #if FLX_SOUND_SYSTEM , sound:FlxSound #end):Void
	{
		@:privateAccess
		anim.buttonMap.set(button, {Callbacks: callbacks, #if FLX_SOUND_SYSTEM Sound:  sound #end});
	}

	function setTheSettings(?Settings:Settings):Void
	{
		anim.framerate = anim.coolParse.MD.FRT;
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
				anim.framerate = (Settings.FrameRate > 0 ? anim.coolParse.MD.FRT : Settings.FrameRate);
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
