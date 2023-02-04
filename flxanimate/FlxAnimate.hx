package flxanimate;

import flxanimate.geom.FlxMatrix3D;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;
import openfl.Vector;
import openfl.display.Sprite;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
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
import flxanimate.graphics.tile.FlxDrawSpriteQuadsItem;

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

	// #if FLX_SOUND_SYSTEM
	// public var audio:FlxSound;
	// #end
	
	// public var rectangle:FlxRect;
	
	public var showPivot:Bool = #if debug true #else false #end;

	var _pivot:FlxFrame;

	var _sprite:Sprite;
	
	/**
	 * # Description
	 * The `FlxAnimate` class calculates in real time a texture atlas through
	 * ## WARNINGS
	 * - This does **NOT** convert the frames into a spritesheet
	 * - Since this is some sort of beta, expect that there could be some inconveniences (bugs, crashes, etc).
	 *
	 * @param X 		The initial X position of the sprite.
	 * @param Y 		The initial Y position of the sprite.
	 * @param Path      The path to the texture atlas, **NOT** the path of the any of the files inside the texture atlas (`Animation.json`, `spritemap.json`, etc).
	 * @param Settings  Optional settings for the animation (antialiasing, framerate, reversed, etc.).
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Path:String, ?Settings:Settings)
	{
		super(X, Y);
		_sprite = new Sprite();
		anim = new FlxAnim(this);
		if (Path != null)
			loadAtlas(Path);
		if (Settings != null)
			setTheSettings(Settings);
		@:privateAccess
		_pivot = new FlxFrame(FlxGraphic.fromBitmapData(Assets.getBitmapData("flxanimate/images/pivot.png")));
		_pivot.frame = new FlxRect(0,0,_pivot.parent.width,_pivot.parent.height);
		_pivot.name = "pivot";

		camera.canvas.addChild(_sprite);
	}

	public function loadAtlas(Path:String)
	{
		if (!Assets.exists('$Path/Animation.json') && haxe.io.Path.extension(Path) != "zip")
		{
			FlxG.log.error('Animation file not found in specified path: "$path", have you written the correct path?');
			return;
		}
		anim._loadAtlas(atlasSetting(Path));
		frames = FlxAnimateFrames.fromTextureAtlas(Path);
	}
	/**
	 * the function `draw()` renders the symbol that `anim` has currently plus a pivot that you can toggle on or off.
	 */
	public override function draw():Void
	{
		_sprite.removeChildren();
		_sprite.graphics.clear();
		var matrix = new FlxMatrix();
		matrix.concat(_matrix);
		matrix.concat(anim.curInstance.matrix);
		@:privateAccess
		var cTransform = colorTransform.__clone();
		cTransform.concat(anim.curInstance.symbol._colorEffect); 
		
		var point = getScreenPosition(_point, camera).subtractPoint(offset);
		matrix.translate(point.x, point.y);
		_sprite.transform.matrix = matrix;
		_sprite.transform.colorTransform = cTransform;
		parseElement(anim.curInstance, anim.curFrame, _sprite);
		#if FLX_DEBUG
		FlxBasic.visibleCount++;
		#end
		if (showPivot)
			drawLimb(_pivot, new FlxMatrix());
	}
	/**
	 * This basically renders an element of any kind, both limbs and symbols.
	 * It should be considered as the main function that makes rendering a symbol possible.
	 */
	function parseElement(instance:FlxElement, curFrame:Int, sprite:Sprite)
	{
		if (instance.bitmap != null)
		{
			if (frames.getByName(instance.bitmap) != null)
			{
				drawQuads(sprite, instance);
			}
			return;
		}
		
		var symbol = anim.symbolDictionary.get(instance.symbol.name);
		@:privateAccess
		var _spr = symbol.toSprite();
		_spr.transform.matrix = instance.matrix;
		_spr.transform.colorTransform = instance.symbol._colorEffect;
		@:privateAccess
		sprite.addChild(_spr);
		
		var firstFrame:Int = instance.symbol.firstFrame + curFrame;
		switch (instance.symbol.type)
		{
			case Button: firstFrame = setButtonFrames(firstFrame);
			default:
		}

		firstFrame = switch (instance.symbol.loop)
		{
			case Loop: firstFrame % symbol.length;
			case PlayOnce: cast FlxMath.bound(firstFrame, 0, symbol.length - 1);
			default: firstFrame;
		}
		
		var layers = symbol.timeline.getList();
		var mask:String = "";
		for (i in 0...layers.length)
		{
			var layer = layers[layers.length - 1 - i];

			@:privateAccess
			var spr:Sprite = cast _spr.getChildByName(layer.name);
			spr.visible = (!layer.visible && sprite == _sprite) ? false : true;

			if (layer.type.getName() == "Clipped")
			{
				@:privateAccess
				spr.mask = _spr.getChildByName(layer.type.getParameters()[0]);
			}
			else
				spr.mask = null;


			var frame = layer.get(firstFrame);
			if (frame == null) continue;

			if (frame.callbacks != null && firstFrame == frame.index && symbol._shootCallback)
			{
				frame.fireCallbacks();
			}

			spr.transform.colorTransform = frame._colorEffect;

			for (element in frame.getList())
			{
				var firstframe = 0;
				if (element.symbol != null && element.symbol.loop != SingleFrame)
				{
					firstframe = firstFrame - frame.index;
				}
				parseElement(element, firstframe, spr);
			}
		}
	}

	function drawQuads(sprite:Sprite, instance:FlxElement)
	{
		var bitmap = frames.getByName(instance.bitmap);
		var shader = (shader == null) ? bitmap.parent.shader : shader;
		shader.bitmap.input = bitmap.parent.bitmap;
		var matrix = instance.matrix;
		shader.alpha.value = [1];
		shader.bitmap.filter = (antialiasing) ? LINEAR : NEAREST;

		sprite.graphics.clear();
		sprite.graphics.beginShaderFill(shader);
		var matrix = new Vector([matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty]);
		sprite.graphics.drawQuads(new Vector([bitmap.frame.x, bitmap.frame.y, bitmap.frame.width, bitmap.frame.height]), null, matrix);
		sprite.graphics.endFill();
	}
	function startSpriteBatch(camera:FlxCamera, sprite:Sprite)
	{
		var currentDrawItem = null, headTiles = null, storageTilesHead = null, itemToReturn:FlxDrawSpriteQuadsItem = null;
		@:privateAccess
		if (true)
		{
			currentDrawItem = camera._currentDrawItem;
			headTiles = camera._headTiles;
			storageTilesHead = FlxCamera._storageTilesHead;
		}
		if (currentDrawItem != null 
			&& (headTiles is FlxDrawSpriteQuadsItem) 
			&& cast (headTiles, FlxDrawSpriteQuadsItem).sprite == sprite
			&& cast (headTiles, FlxDrawSpriteQuadsItem)._camera == camera)
		{
			return;
		}

		if (storageTilesHead != null && (storageTilesHead is FlxDrawSpriteQuadsItem))
		{
			itemToReturn = cast storageTilesHead;
			var newHead = storageTilesHead.nextTyped;
			itemToReturn.reset();
			storageTilesHead = newHead;
		}
		else			
			itemToReturn = new FlxDrawSpriteQuadsItem();

		itemToReturn.sprite = sprite;

		itemToReturn.nextTyped = headTiles;
		headTiles = itemToReturn;
		@:privateAccess
		if (camera._headOfDrawStack == null)
		{
			camera._headOfDrawStack = itemToReturn;
		}
		if (currentDrawItem != null)
		{
			currentDrawItem.next = itemToReturn;
		}

		currentDrawItem = itemToReturn;
	}
	var pressed:Bool = false;
	function setButtonFrames(frame:Int)
	{
		var badPress:Bool = false;
		var goodPress:Bool = false;
		#if !mobile
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
			frame = (FlxG.mouse.pressed) ? 2 : 1;

			if (FlxG.mouse.justReleased && pressed)
			{
				if (event != null)
					new ButtonEvent((event.Callbacks != null) ? event.Callbacks.OnRelease : null #if FLX_SOUND_SYSTEM, event.Sound #end).fire();
				pressed = false;
			}
		}
		else
		{
			frame = 0;
		}
		#else
		FlxG.log.error("Button stuff isn't available for mobile!");
		#end
		return frame;
	}
	function drawLimb(limb:FlxFrame, _matrix:FlxMatrix, ?colorTransform:ColorTransform = null, ?mask:FlxFrame = null)
	{
		if (alpha == 0 || colorTransform != null && (colorTransform.alphaMultiplier == 0 || colorTransform.alphaOffset == -255) || limb == null || limb.type == EMPTY)
			return;
		var matrix = new FlxMatrix();
		matrix.concat(_matrix);
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !limbOnScreen(limb, _matrix, camera))
				return;
			
			getScreenPosition(_point, camera).subtractPoint(offset);
			matrix.translate(-origin.x, -origin.y);
			if (limb.name != "pivot")
				matrix.scale(scale.x, scale.y);
			else 
				matrix.a = matrix.d = 0.7 / camera.zoom;
			_point.addPoint(origin);
			if (isPixelPerfectRender(camera))
		    {
			    _point.floor();
		    }

			matrix.translate(_point.x, _point.y);
			camera.drawPixels(limb, null, matrix, colorTransform, blend, antialiasing);
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
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.pressed.B)
		{
			_sprite.filters = [new openfl.filters.BlurFilter(4, 4, 1)];
		}
	}
	// function checkSize(limb:FlxFrame, m:FlxMatrix)
	// {
	// 	// var rect = new Rectangle(x,y,limb.frame.width,limb.frame.height);
	// 	// @:privateAccess
	// 	// rect.__transform(rect, m);
	// 	return {width: rect.width, height: rect.height};
	// }
	var oldMatrix:FlxMatrix;
	override function set_flipX(Value:Bool)
	{
		if (oldMatrix == null)
		{
			oldMatrix = new FlxMatrix();
			oldMatrix.concat(_matrix);
		}
		if (Value)
		{
			_matrix.a = -oldMatrix.a;
			_matrix.c = -oldMatrix.c;
		}
		else
		{
			_matrix.a = oldMatrix.a;
			_matrix.c = oldMatrix.c;
		}
		return Value;
	}
	override function set_flipY(Value:Bool)
	{
		if (oldMatrix == null)
		{
			oldMatrix = new FlxMatrix();
			oldMatrix.concat(_matrix);
		}
		if (Value)
		{
			_matrix.b = -oldMatrix.b;
			_matrix.d = -oldMatrix.d;
		}
		else
		{
			_matrix.b = oldMatrix.b;
			_matrix.d = oldMatrix.d;
		}
		return Value;
	}

	override function destroy()      
	{                                                                
		if (anim != null)
			anim.destroy();
		anim = null;
		_sprite = null;
		// #if FLX_SOUND_SYSTEM
		// if (audio != null)
		// 	audio.destroy();
		// #end
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
		@:privateAccess
		if (true)
		{
			antialiasing = Settings.Antialiasing;
			if (Settings.ButtonSettings != null)
			{
				anim.buttonMap = Settings.ButtonSettings;
				if (anim.symbolType != Button)
					anim.symbolType = Button;
			}
			if (Settings.Reversed != null)
				anim.reversed = Settings.Reversed;
			if (Settings.FrameRate != null)
				anim.framerate = (Settings.FrameRate > 0) ? anim.metadata.frameRate : Settings.FrameRate;
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
			var thing = Zip.readZip(Assets.getBytes(Path));
			
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
