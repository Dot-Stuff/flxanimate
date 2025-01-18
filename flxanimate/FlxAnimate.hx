package flxanimate;

import openfl.geom.Point;
import flxanimate.interfaces.IFilterable;
import openfl.display.BlendMode;
import flixel.graphics.frames.FlxFramesCollection;
import haxe.extern.EitherType;
import flxanimate.display.FlxAnimateFilterRenderer;
import openfl.filters.BitmapFilter;
import flxanimate.geom.FlxMatrix3D;
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
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
import flixel.FlxG;
import flxanimate.data.AnimationData;
import flixel.FlxSprite;
import flxanimate.animate.FlxAnim;
import flxanimate.frames.FlxAnimateFrames;
import flixel.math.FlxMatrix;
import openfl.geom.ColorTransform;
import flixel.math.FlxMath;
import flixel.FlxBasic;
import flixel.graphics.frames.FlxFramesCollection;

using flixel.util.FlxColorTransformUtil;

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

@:access(openfl.geom.ColorTransform)
@:access(openfl.geom.Rectangle)
@:access(flixel.graphics.frames.FlxFrame)
@:access(flixel.FlxCamera)
class FlxAnimate extends FlxSprite
{
	public var anim(default, null):FlxAnim;

	// #if FLX_SOUND_SYSTEM
	// public var audio:FlxSound;
	// #end

	var rect:Rectangle;

	var _symbols:Array<FlxSymbol>;

	public var filters:Array<BitmapFilter> = null;

	public var showPivot(default, set):Bool = false;

	var _pivot:FlxFrame;
	var _indicator:FlxFrame;

	var renderer:FlxAnimateFilterRenderer = new FlxAnimateFilterRenderer();

	var filterCamera:FlxCamera;

	public var relativeX:Float = 0;

	public var relativeY:Float = 0;

	/**
	 * # Description
	 * The `FlxAnimate` class calculates in real time a texture atlas through
	 * ## WARNINGS
	 * - This does **NOT** convert the frames into a spritesheet
	 * - Since this is some sort of beta, expect that there could be some inconveniences (bugs, crashes, etc).
	 *
	 * @param X 		The initial X position of the sprite.
	 * @param Y 		The initial Y position of the sprite.
	 * @param directoryPath	The directory/folder where the atlas is located, or a zip compressed directory of our texture atlas json + spritesheet.
	 * 				 		**NOT** the path of the any of the files inside the texture atlas (`Animation.json`, `spritemap.json`, etc).
	 * @param Settings  Optional settings for the animation (antialiasing, framerate, reversed, etc.).
	 */
	public function new(X:Float = 0, Y:Float = 0, ?directoryPath:String, ?Settings:Settings)
	{
		super(X, Y);
		anim = new FlxAnim(this);
		showPivot = false;
		if (directoryPath != null)
			loadAtlas(directoryPath);
		if (Settings != null)
			setTheSettings(Settings);


		rect = Rectangle.__pool.get();
	}

	/**
	 * Loads a regular atlas.
	 * @param Path The path where the atlas is located. Must be the folder, **NOT** any of the contents of it!
	 */
	public function loadAtlas(atlasDirectory:String)
	{
		var p = haxe.io.Path.removeTrailingSlashes(haxe.io.Path.normalize(atlasDirectory));
		if (!Assets.exists('$atlasDirectory/Animation.json') && haxe.io.Path.extension(atlasDirectory) != "zip")
		{
			FlxG.log.error('Animation file not found in specified path: "${atlasDirectory}", have you written the correct path?');
			return;
		}
		if (!Assets.exists('$atlasDirectory/metadata.json'))
			loadSeparateAtlas(atlasSetting(atlasDirectory), FlxAnimateFrames.fromTextureAtlas(atlasDirectory));
		else
		{
			loadSeparateAtlas(null, FlxAnimateFrames.fromTextureAtlas(atlasDirectory));
			
			anim._loadExAtlas(atlasDirectory);
		}
	}
	/**
	 * Function in handy to load atlases that share same animation/frames but dont necessarily mean it comes together.
	 * @param animation The animation file. This should be the content of the `JSON`, **NOT** the path of it.
	 * @param frames The collection of frames.
	 */
	public function loadSeparateAtlas(?animation:String = null, ?frames:FlxFramesCollection = null)
	{
		if (frames != null)
			this.frames = frames;
		if (animation != null)
		{
			/*
			var eReg = ~/"(F|filters)": /,
				eReg2 = ~/(\{([^{}]|(?R))*\})/s,
				eReg3 = ~/("(.+)")/;

			var lastMatch = 0, position, filterPos = null;


			while (eReg.matchSub(animation, lastMatch))
			{
				position = eReg.matchedPos();

				if (eReg2.matchSub(animation, position.pos + position.len))
				{

					var string = eReg2.matched(0);
					if (lastMatch == 0)
					{
						var pos = eReg2.matchedPos();
						filterPos = {pos: position.pos, len: position.len + (pos.pos - position.pos + pos.len)};
					}
					position = eReg2.matchedPos();

					var len = 0;
					var repeated:Map<String, Int> = [];
					while (eReg3.matchSub(animation, position.pos + len, filterPos.pos + filterPos.len))
					{
						var filter = eReg3.matched(0);
						position = eReg3.matchedPos();


						if (repeated.exists(filter))
						{
							var mod = '"${filter.substring(1, filter.length - 1)}_${repeated.get(filter) + 1}"';

							animation = animation.substring(0, position.pos) + mod + animation.substring(position.pos + position.len);
							repeated.set(filter, repeated.get(filter) + 1);
						}
						else
							repeated.set(filter, 0);

						len += position.len;

						if (eReg2.matchSub(animation, position.pos + len))
						{
							var pos = eReg2.matchedPos();
							len += (pos.pos - position.pos) + pos.len;
						}
					}

					position = eReg2.matchedPos();
				}

				lastMatch = position.pos + position.len;
			}
			*/
			var json:AnimAtlas = haxe.Json.parse(animation);

			anim._loadAtlas(json);

			if (anim != null && anim.curInstance != null)
				origin = anim.curInstance.symbol.transformationPoint;

		}
	}

	/**
	 * the function `draw()` renders the symbol that `anim` has currently plus a pivot that you can toggle on or off.
	 */
	public override function draw():Void
	{
    
    if( alpha <= 0) return;
		_matrix.identity();
		if (flipX)
		{
			_matrix.a *= -1;

			//_matrix.tx += width;

		}
		if (flipY)
		{
			_matrix.d *= -1;
			//_matrix.ty += height;
		}

		_flashRect.setEmpty();


		parseElement(anim.curInstance, _matrix, colorTransform, cameras, scrollFactor);

		width = _flashRect.width;
		height = _flashRect.height;
		frameWidth = Math.round(width);
		frameHeight = Math.round(height);

		relativeX = _flashRect.x - x;
		relativeY = _flashRect.y - y;

		if (showPivot)
		{
			_tmpMat.setTo(1, 0, 0, 1, origin.x - _pivot.frame.width * 0.5, origin.y - _pivot.frame.height * 0.5);
			drawLimb(_pivot, _tmpMat, cameras);

			_tmpMat.setTo(1, 0, 0, 1, -_indicator.frame.width * 0.5, -_indicator.frame.height * 0.5);
			drawLimb(_indicator, _tmpMat, cameras);
		}
	}

	var _camArr:Array<FlxCamera> = [null];
	function _singleCam(cam:FlxCamera):Array<FlxCamera>
	{
		_camArr[0] = cam;
		return _camArr;
	}

	var _elemObj:{instance:FlxElement} = {instance: null};
	function _elemInstance(?instance:FlxElement)
	{
		_elemObj.instance = instance;
		return _elemObj;
	}

	var st = 0;
	function parseElement(instance:FlxElement, m:FlxMatrix, colorFilter:ColorTransform, ?filterInstance:{?instance:FlxElement} = null, ?cameras:Array<FlxCamera> = null, ?scrollFactor:FlxPoint = null)
	{
		if (instance == null || !instance.visible)
			return;

		var mainSymbol = instance == anim.curInstance;
		var filterin = filterInstance != null;

		var skipFilters = anim.metadata.skipFilters;

		if (cameras == null)
			cameras = this.cameras;


		//if (scrollFactor == null)
		//	scrollFactor = FlxPoint.get();

		//var scroll = new FlxPoint().copyFrom(scrollFactor);

		var matrix = instance._matrix;

		matrix.copyFrom(instance.matrix);
		matrix.translate(instance.x, instance.y);
		matrix.concat(m);


		var colorEffect = instance._color;
		colorEffect.__copyFrom(colorFilter);


		var symbol = (instance.symbol != null) ? anim.symbolDictionary.get(instance.symbol.name) : null;

		if (instance.bitmap == null && symbol == null)
			return;

		if (instance.bitmap != null)
		{
			drawLimb(frames.getByName(instance.bitmap), matrix, colorEffect, filterin, cameras);
			return;
		}
		var cacheToBitmap = !skipFilters && (instance.symbol.cacheAsBitmap || this.filters != null && mainSymbol) && (!filterin || filterin && filterInstance.instance != instance);

		if (cacheToBitmap)
		{
			if (instance.symbol._renderDirty)
			{
				if (filterCamera == null)
					instance.symbol._filterCamera = new FlxCamera(0,0,0,0,1);

				instance.symbol._filterMatrix.copyFrom(instance.symbol.cacheAsBitmapMatrix);

				_col.setMultipliers(1,1,1,1);
				_col.setOffsets(0,0,0,0);
				parseElement(instance, instance.symbol._filterMatrix, _col, _elemInstance(instance), _singleCam(instance.symbol._filterCamera));

				@:privateAccess
				renderFilter(instance.symbol, instance.symbol.filters, renderer);
				instance.symbol._renderDirty = false;

			}
			if (instance.symbol._filterFrame != null)
			{
				if (instance.symbol.colorEffect != null)
					colorEffect.concat(instance.symbol.colorEffect.c_Transform);

				matrix.copyFrom(instance.symbol._filterMatrix);
				matrix.concat(m);


				drawLimb(instance.symbol._filterFrame, matrix, colorEffect, filterin, instance.symbol.blendMode, cameras);
			}
		}
		else
		{
			if (instance.symbol.colorEffect != null && (!filterin || filterin && filterInstance.instance != instance))
				colorEffect.concat(instance.symbol.colorEffect.c_Transform);

			var firstFrame:Int = instance.symbol._curFrame;
			switch (instance.symbol.type)
			{
				case Button: firstFrame = setButtonFrames(firstFrame);
				default:
			}

			var layers = symbol.timeline.getList();

			for (i in 0...layers.length)
			{
				var layer = layers[layers.length - 1 - i];

				if (!layer.visible && (!filterin && mainSymbol || !anim.metadata.showHiddenLayers) /*|| layer.type == Clipper && layer._correctClip*/) continue;

				/*
				if (layer._clipper != null)
				{
					var layer = layer._clipper;
					layer._setCurFrame(firstFrame);
					var frame = layer._currFrame;
					if (layer._filterCamera == null)
						layer._filterCamera = new FlxCamera();
					if (frame._renderDirty)
					{
						renderLayer(frame, new FlxMatrix(), new ColorTransform(), {instance: null}, [layer._filterCamera]);

				// 		layer._filterMatrix.identity();

						frame._renderDirty = false;
					}
				}
				*/

				layer._setCurFrame(firstFrame);

				var frame = layer._currFrame;

				if (frame == null) continue;

				var toBitmap = !skipFilters && frame.filters != null;
				var isMasked = layer._clipper != null;
				var isMasker = layer.type == Clipper;

				var coloreffect = _col;
				coloreffect.__copyFrom(colorEffect);
				if (frame.colorEffect != null)
					coloreffect.concat(frame.colorEffect.__create());

				if (toBitmap || isMasker)
				{
					if (!frame._renderDirty && layer._filterFrame != null)
					{
						var mat = _tmpMat;
						mat.copyFrom(layer._filterMatrix);
						mat.concat(matrix);

						drawLimb(layer._filterFrame, mat, coloreffect, filterin, (isMasked) ? _singleCam(layer._clipper.maskCamera) : cameras);
						continue;
					}
					else
					{
						if (layer._filterCamera == null)
							layer._filterCamera = new FlxCamera();
						if (isMasker && layer._filterFrame != null && frame.getList().length == 0)
							layer.updateBitmaps(layer._bmp1.rect);
					}
				}

				if (isMasked && (layer._clipper == null || layer._clipper._currFrame == null || layer._clipper._currFrame.getList().length == 0))
				{
					isMasked = false;
				}

				if (isMasked)
				{
					if (layer._clipper.maskCamera == null)
						layer._clipper.maskCamera = new FlxCamera();
					if (!frame._renderDirty)
						continue;
				}

				_tmpMat.identity();
				renderLayer(frame, (toBitmap || isMasker || isMasked) ? _tmpMat : matrix, coloreffect, (toBitmap || isMasker || isMasked) ? _elemInstance(null) : filterInstance, (toBitmap || isMasker) ? _singleCam(layer._filterCamera) : (isMasked) ? _singleCam(layer._clipper.maskCamera) : cameras);

				if (toBitmap)
				{
					layer._filterMatrix.identity();

					renderFilter(layer, frame.filters, renderer, null);

					frame._renderDirty = false;

					var mat = _tmpMat;
					mat.copyFrom(layer._filterMatrix);
					mat.concat(matrix);

					drawLimb(layer._filterFrame, mat, coloreffect, filterin, (isMasked) ? _singleCam(layer._clipper.maskCamera) : cameras);
				}
				if (isMasker)
				{
					layer._filterMatrix.identity();

					renderMask(layer, renderer);

					var mat = _tmpMat;
					mat.copyFrom(layer._filterMatrix);
					mat.concat(matrix);

					drawLimb(layer._filterFrame, mat, coloreffect, filterin, cameras);
				}
			}
		}
	}
	inline function renderLayer(frame:FlxKeyFrame, matrix:FlxMatrix, colorEffect:ColorTransform, ?instance:{?instance:FlxElement} = null, ?cameras:Array<FlxCamera>)
	{
		for (element in frame.getList())
			parseElement(element, matrix, colorEffect, instance, cameras);
	}
	function renderFilter(filterInstance:IFilterable, filters:Array<BitmapFilter>, renderer:FlxAnimateFilterRenderer, ?mask:FlxCamera)
	{
		var filterCamera = filterInstance._filterCamera;
		filterCamera.render();

		var rect = filterCamera.canvas.getBounds(null);

		if (filters != null && filters.length > 0)
		{
			var extension = Rectangle.__pool.get();

			for (filter in filters)
			{
				@:privateAccess
				extension.__expand(-filter.__leftExtension,
					-filter.__topExtension, filter.__leftExtension
					+ filter.__rightExtension,
					filter.__topExtension
					+ filter.__bottomExtension);
			}
			rect.width += extension.width;
			rect.height += extension.height;
			rect.x = extension.x;
			rect.y = extension.y;

			Rectangle.__pool.release(extension);
		}

		filterInstance.updateBitmaps(rect);

		var gfx = renderer.graphicstoBitmapData(filterCamera.canvas.graphics, filterInstance._bmp1);

		if (gfx == null) return;

		var gfxMask = null;

		var b = Rectangle.__pool.get();

		@:privateAccess
		filterCamera.canvas.__getBounds(b, filterInstance._filterMatrix);

		var point:FlxPoint = null;

		renderer.applyFilter(gfx, filterInstance._filterFrame.parent.bitmap, filterInstance._bmp1, filterInstance._bmp2, filters, rect, gfxMask, point);
		point = FlxDestroyUtil.put(point);

		if (filters != null && filters.length > 0)
			filterInstance._filterMatrix.translate(Math.round((b.x + rect.x)), Math.round((b.y + rect.y)));
		else
			filterInstance._filterMatrix.translate(Math.round((rect.x)), Math.round(rect.y));

		@:privateAccess
		filterCamera.clearDrawStack();
		filterCamera.canvas.graphics.clear();

		Rectangle.__pool.release(b);
	}

	function renderMask(instance:FlxLayer, renderer:FlxAnimateFilterRenderer)
	{
		var masker = instance._filterCamera;
		masker.render();

		var bounds = masker.canvas.getBounds(null);

		if (bounds.width == 0)
		{
			@:privateAccess
			masker.clearDrawStack();
			masker.canvas.graphics.clear();

			return;
		}
		instance.updateBitmaps(bounds);

		var mask = instance.maskCamera;

		mask.render();
		var mBounds = mask.canvas.getBounds(null);

		if (mBounds.width == 0)
		{
			@:privateAccess
			masker.clearDrawStack();
			masker.canvas.graphics.clear();

			@:privateAccess
			mask.clearDrawStack();
			mask.canvas.graphics.clear();
			return;
		}
		var p = FlxPoint.get(mBounds.x, mBounds.y);

		p.x -= bounds.x;
		p.y -= bounds.y;

		var lMask = renderer.graphicstoBitmapData(mask.canvas.graphics, instance._bmp1, p);
		var mrBmp = renderer.graphicstoBitmapData(masker.canvas.graphics, instance._bmp2);

		p.put();


		// instance._filterFrame.parent.bitmap.copyPixels(instance._bmp1, instance._bmp1.rect, instance._bmp1.rect.topLeft, instance._bmp2, instance._bmp2.rect.topLeft, true);
		renderer.applyFilter(lMask, instance._filterFrame.parent.bitmap, lMask, null, null, mrBmp);


		instance._filterMatrix.translate((Math.round(bounds.x)), (Math.round(bounds.y)));

		@:privateAccess
		mask.clearDrawStack();
		mask.canvas.graphics.clear();

		@:privateAccess
		masker.clearDrawStack();
		masker.canvas.graphics.clear();


	}

	var pressed:Bool = false;
	function setButtonFrames(frame:Int)
	{
		var badPress:Bool = false;
		var goodPress:Bool = false;
		#if FLX_MOUSE
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
	var _mat:FlxMatrix = new FlxMatrix();
	var _tmpMat:FlxMatrix = new FlxMatrix();
	var _col:ColorTransform = new ColorTransform();

	function drawLimb(limb:FlxFrame, _matrix:FlxMatrix, ?colorTransform:ColorTransform = null, filterin:Bool = false, ?blendMode:BlendMode, ?scrollFactor:FlxPoint = null, cameras:Array<FlxCamera> = null)
	{
		if (colorTransform != null && (colorTransform.alphaMultiplier == 0 || colorTransform.alphaOffset == -255) || limb == null || limb.type == EMPTY)
			return;

		if (blendMode == null)
			blendMode = BlendMode.NORMAL;

		if (cameras == null)
			cameras = this.cameras;

		for (camera in cameras)
		{
			var matrix = _mat;
			matrix.identity();
			limb.prepareMatrix(matrix);
			matrix.concat(_matrix);

			if (camera == null || !camera.visible || !camera.exists)
				return;


			if (!filterin)
			{
				getScreenPosition(_point, camera).subtractPoint(offset);
				if (limb != _pivot && limb != _indicator)
				{
					matrix.translate(-origin.x, -origin.y);

					matrix.scale(scale.x, scale.y);

					if (bakedRotationAngle <= 0)
					{
						updateTrig();

						if (angle != 0)
							matrix.rotateWithTrig(_cosAngle, _sinAngle);
					}

					_point.addPoint(origin);
				}
				else
				{
					matrix.scale(0.9, 0.9);

					matrix.a /= camera.zoom;
					matrix.d /= camera.zoom;
					matrix.tx /= camera.zoom;
					matrix.ty /= camera.zoom;
				}

				//if (limb.name == "0003")
				//{
				//	// matrix.tx = 50;
				//	// matrix.ty = -100;
				//}


				if (isPixelPerfectRender(camera))
				{
					_point.floor();
				}

				matrix.translate(_point.x, _point.y);

				if (!limbOnScreen(limb, matrix, camera))
					continue;
			}
			camera.drawPixels(limb, null, matrix, colorTransform, blendMode, (!filterin) ? antialiasing : true, this.shader);
		}

		width = rect.width;
		height = rect.height;
		frameWidth = Std.int(width);
		frameHeight = Std.int(height);

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug && limb != _pivot && limb != _indicator)
		{
			var oldX = x;
			var oldY = y;

			x = rect.x;
			y = rect.y;
			drawDebug();
			x = oldX;
			y = oldY;
		}
		#end
		#if FLX_DEBUG
		FlxBasic.visibleCount++;
		#end
	}

	function limbOnScreen(limb:FlxFrame, m:FlxMatrix, ?Camera:FlxCamera = null)
	{
		if (Camera == null)
			Camera = FlxG.camera;

		limb.frame.copyToFlash(rect);

		rect.offset(-rect.x, -rect.y);

		rect.__transform(rect, m);

		_point.copyFromFlash(rect.topLeft);

		//if ([_indicator, _pivot].indexOf(limb) == -1)
		if (_indicator != limb && _pivot != limb)
			_flashRect = _flashRect.union(rect);

		return Camera.containsPoint(_point, rect.width, rect.height);
	}

	override function destroy()
	{
		anim = FlxDestroyUtil.destroy(anim);

		_mat = null;
		_tmpMat = null;
		_col = null;

		_camArr = null;
		_elemObj = null;

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

	function set_showPivot(value:Bool)
	{
		if (value != showPivot)
		{
			showPivot = value;

			if (showPivot && _pivot == null)
			{
				_pivot = FlxGraphic.fromBitmapData(Assets.getBitmapData("flxanimate/images/pivot.png"), "__pivot").imageFrame.frame;
				_indicator = FlxGraphic.fromBitmapData(Assets.getBitmapData("flxanimate/images/indicator.png"), "__indicator").imageFrame.frame;
			}
		}

		return value;
	}

	/**
	 * Sets variables via a typedef. Something similar as having an ID class.
	 * @param Settings
	 */
	public function setTheSettings(?Settings:Settings):Void
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
				anim.framerate = (Settings.FrameRate <= 0) ? anim.metadata.frameRate : Settings.FrameRate;
			if (Settings.OnComplete != null)
				anim.onComplete.add(Settings.OnComplete);
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

	public static function fromSettings()
	{}

	function atlasSetting(directoryPath:String)
	{
		var jsontxt:String = null;
		if (haxe.io.Path.extension(directoryPath) == "zip")
		{
			var thing = Zip.readZip(Assets.getBytes(directoryPath));

			for (list in Zip.unzip(thing))
			{
				if (list.fileName.indexOf("Animation.json") != -1)
				{
					jsontxt = list.data.toString();
					thing.remove(list);
					continue;
				}
			}
			@:privateAccess
			FlxAnimateFrames.zip = thing;
		}
		else
			jsontxt = openfl.Assets.getText('$directoryPath/Animation.json');

		return jsontxt;
	}
}
