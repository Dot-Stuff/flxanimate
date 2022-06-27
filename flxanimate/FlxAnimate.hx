package flxanimate;

import flixel.util.FlxDestroyUtil;
import flixel.math.FlxRect;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flxanimate.animate.*;
import flxanimate.zip.Zip;
import openfl.Assets;
import haxe.io.BytesInput;
import flixel.system.FlxSound;
import flixel.FlxG;
import flxanimate.data.AnimationData;
import flixel.FlxSprite;
import flxanimate.animate.FlxAnim;
import flxanimate.frames.FlxAnimateFrames;
import flixel.math.FlxMatrix;
import openfl.geom.ColorTransform;
import flixel.math.FlxMath;
import flixel.FlxBasic;

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
	public var anim(default, null):FlxAnim;

	#if FLX_SOUND_SYSTEM
	public var audio:FlxSound;
	#end
	
	public var showPivot:Bool = false;

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
		if (!Assets.exists('$Path/Animation.json') && haxe.io.Path.extension(Path) != "zip")
		{
			FlxG.log.error('Animation file not found in specified path: "$path", have you written the correct path?');
			return;
		}

		var jsontxt:AnimAtlas = atlasSetting(Path);
		anim = new FlxAnim(jsontxt);
		anim.setShit();
		setTheSettings(Settings);
		super(X, Y);
		frames = FlxAnimateFrames.fromTextureAtlas(Path);
		jsontxt = null;
	}

	public override function draw():Void
	{
		@:privateAccess
		parseSymbol(anim.curSymbol, anim._matrix, anim.curFrame, anim.symbolType, anim.colorTransform);
	}

	function parseSymbol(symbol:FlxSymbol, m:FlxMatrix, FF:Int, symbolType:SymbolType, colorFilter:ColorTransform)
	{
		if ([button, "button"].indexOf(symbolType) != -1)
		{
			setButtonFrames();
		}
		var lbl:Null<String> = null;
		for (layer in symbol.timeline.L)
		{
			if (!symbol.layers.contains(layer.LN)) continue;
			
			var selectedFrame = layer.FR[FF];
			
			if (selectedFrame == null) continue;

			if (selectedFrame.N != null)
			{
				symbol.labels.get(selectedFrame.N).fireCallbacks();
			}
			for (element in selectedFrame.E)
			{
				var isSymbol = element.SI != null;
				var m3d = (isSymbol) ? element.SI.M3D : element.ASI.M3D;
				var matrix = new FlxMatrix(m3d[0], m3d[1], m3d[4], m3d[5], m3d[12], m3d[13]);
				matrix.concat(m);
				var colorF = new ColorTransform();
				colorF.concat(colorEffect(selectedFrame.C));
				colorF.concat(colorFilter);
				colorF.concat(colorEffect(element.SI.C));
				if (element.SI.bitmap == null && isSymbol)
				{
					var symbol = anim.symbolDictionary.get(element.SI.SN);
					parseSymbol(symbol, matrix, symbol.frameControl(element.SI.FF,element.SI.LP), element.SI.ST, colorF);
					continue;
				}

				drawLimb(frames.getByName((isSymbol) ? element.SI.bitmap.N : element.ASI.N), matrix, colorF);
			}
		}
	}

	static function colorEffect(sInstance:ColorEffects)
	{
		var CT = new ColorTransform();
		if (sInstance == null) return CT;
		switch (sInstance.M)
		{
			case Tint, "Tint":
			{
				var color = flixel.util.FlxColor.fromString(sInstance.TC);
				var opacity = sInstance.TM;
				CT.redMultiplier -= opacity;
				CT.redOffset = Math.round(color.red * opacity);
				CT.greenMultiplier -= opacity;
				CT.greenOffset = Math.round(color.green * opacity);
				CT.blueMultiplier -= opacity;
				CT.blueOffset = Math.round(color.blue * opacity);
			}
			case Alpha, "Alpha":
			{
				CT.alphaMultiplier = sInstance.AM;
			}
			case Brightness, "Brightness":
			{
				CT.redMultiplier = CT.greenMultiplier = CT.blueMultiplier -= Math.abs(sInstance.BRT);
				if (sInstance.BRT >= 0)
					CT.redOffset = CT.greenOffset = CT.blueOffset = 255 * sInstance.BRT;
			}
			case Advanced, "Advanced":
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
		return CT;
	}

	var pressed:Bool = false;
	function setButtonFrames()
	{
		var badPress:Bool = false;
		var goodPress:Bool = false;
		if (FlxG.mouse.pressed && FlxG.mouse.overlaps(this))
			goodPress = true;
		if (FlxG.mouse.pressed && !FlxG.mouse.overlaps(this) && !goodPress)
		{
			badPress = true;
		}
		if (!FlxG.mouse.pressed)
		{
			badPress = false;
			goodPress = false;
		}
		if (FlxG.mouse.overlaps(this) && !badPress)
		{
			@:privateAccess
			var event = anim.buttonMap.get(anim.curSymbol.name);
			if (FlxG.mouse.justPressed && !pressed)
			{
				if (event != null)
					new ButtonEvent((event.Callbacks != null) ? event.Callbacks.OnClick : null #if FLX_SOUND_SYSTEM, event.Sound #end).fire();
				pressed = true;
			}
			if (FlxG.mouse.pressed)
			{
				anim.curFrame = 2;
			}
			else
			{
				anim.curFrame = 1;
			}
			if (FlxG.mouse.justReleased && pressed)
			{
				if (event != null)
					new ButtonEvent((event.Callbacks != null) ? event.Callbacks.OnRelease : null #if FLX_SOUND_SYSTEM, event.Sound #end).fire();
				pressed = false;
			}
		}
		else
		{
			anim.curFrame = 0;
		}
	}
	function drawLimb(limb:FlxFrame, _matrix:FlxMatrix, colorTransform:ColorTransform)
	{
		if (alpha == 0 || colorTransform.alphaMultiplier == 0 || colorTransform.alphaOffset == -255 || limb == null || limb.type == EMPTY)
			return;
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !limbOnScreen(limb, _matrix, camera))
				return;
			getScreenPosition(_point, camera).subtractPoint(offset);

			if (isPixelPerfectRender(camera))
		    {
			    _point.floor();
		    }
			_matrix.translate(_point.x, _point.y);
			camera.drawPixels(limb, null, _matrix, colorTransform, blend, antialiasing, AnimationData.filters.shader);

			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}
	function limbOnScreen(limb:FlxFrame, m:FlxMatrix, ?Camera:FlxCamera)
	{
		if (Camera == null)
			Camera = FlxG.camera;


		var minX:Float = x + m.tx - offset.x - scrollFactor.x * Camera.scroll.x;
		var minY:Float = y + m.ty - offset.y - scrollFactor.y * Camera.scroll.y;

		var radiusX:Float =  limb.frame.width * Math.max(1, m.a);
		var radiusY:Float = limb.frame.height * Math.max(1, m.d);
		var radius:Float = Math.max(radiusX, radiusY);
		radius *= FlxMath.SQUARE_ROOT_OF_TWO;
		minY -= radius;
		minX -= radius;
		radius *= 2;

		_point.set(minX, minY);

		return Camera.containsPoint(_point, radius, radius);
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

	override function destroy()      
	{                                                                
		if (anim != null)
			anim.destroy();
		anim = null;
		#if FLX_SOUND_SYSTEM
		if (audio != null)
			audio.destroy();
		#end
		for (frame in frames.frames)
		{
			frame.parent = FlxDestroyUtil.destroy(frame.parent);
			frame.destroy();
		}
		for (frame in frames.framesHash.iterator())
		{
			frame.parent = FlxDestroyUtil.destroy(frame.parent);
			frame.destroy();
		}
		super.destroy();
	}

	public override function updateAnimation(elapsed:Float) 
	{
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
			antialiasing = Settings.Antialiasing;
			if (Settings.ButtonSettings != null)
			{
				anim.buttonMap = Settings.ButtonSettings;
				if ([button, "button"].indexOf(anim.symbolType) == -1)
					anim.symbolType = button;
			}
			if (Settings.Reversed != null)
				anim.reversed = Settings.Reversed;
			if (Settings.FrameRate != null)
				anim.framerate = (Settings.FrameRate > 0 ? anim.coolParse.MD.FRT : Settings.FrameRate);
			if (Settings.OnComplete != null)
				anim.onComplete = Settings.OnComplete;
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
