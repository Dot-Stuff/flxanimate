package flxanimate.display;

import openfl.utils.ByteArray;
import flxanimate.filters.MaskShader;
import openfl.filters.ShaderFilter;
import flixel.FlxCamera;
import openfl.display.BlendMode;
import openfl.display3D.Context3DClearMask;
import openfl.display3D.Context3D;
import flixel.math.FlxPoint;
import lime.graphics.cairo.Cairo;
import openfl.display.DisplayObjectRenderer;
import openfl.filters.BlurFilter;
import openfl.display.Graphics;
import flixel.FlxG;
import openfl.display.OpenGLRenderer;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.filters.BitmapFilter;
import openfl.geom.Matrix;
import openfl.geom.ColorTransform;
import openfl.geom.Point;

import openfl.display._internal.Context3DGraphics;
#if (js && html5)
import openfl.display.CanvasRenderer;
import openfl.display._internal.CanvasGraphics as GfxRenderer;
import lime._internal.graphics.ImageCanvasUtil;
#else
import openfl.display.CairoRenderer;
import openfl.display._internal.CairoGraphics as GfxRenderer;
#end


@:access(openfl.display.OpenGLRenderer)
@:access(openfl.filters.BitmapFilter)
@:access(openfl.geom.Rectangle)
@:access(openfl.display.Stage)
@:access(openfl.display.Graphics)
@:access(openfl.display.Shader)
@:access(openfl.display.BitmapData)
@:access(openfl.geom.ColorTransform)
@:access(openfl.display.DisplayObject)
@:access(openfl.display3D.Context3D)
@:access(openfl.display.CanvasRenderer)
@:access(openfl.display.CairoRenderer)
@:access(openfl.display3D.Context3D)
class FlxAnimateFilterRenderer
{
	var renderer:OpenGLRenderer;
	var context:Context3D;
	@:privateAccess
	var maskShader:flxanimate.filters.MaskShader;

	var maskFilter:ShaderFilter;

	public function new()
	{
		// context = new openfl.display3D.Context3D(null);
		renderer = new OpenGLRenderer(FlxG.game.stage.context3D);
		renderer.__worldTransform = new Matrix();
		renderer.__worldColorTransform = new ColorTransform();
		maskShader = new MaskShader();
		maskFilter = new ShaderFilter(maskShader);
	}

	@:noCompletion function setRenderer(renderer:DisplayObjectRenderer, rect:Rectangle)
	{
		@:privateAccess
		if (true)
		{
			var displayObject = FlxG.game;
			var pixelRatio = FlxG.game.stage.__renderer.__pixelRatio;

			var offsetX = rect.x > 0 ? Math.ceil(rect.x) : Math.floor(rect.x);
			var offsetY = rect.y > 0 ? Math.ceil(rect.y) : Math.floor(rect.y);
			if (renderer.__worldTransform == null)
			{
				renderer.__worldTransform = new Matrix();
				renderer.__worldColorTransform = new ColorTransform();
			}
			if (displayObject.__cacheBitmapColorTransform == null) displayObject.__cacheBitmapColorTransform = new ColorTransform();

			renderer.__stage = displayObject.stage;

			renderer.__allowSmoothing = true;
			renderer.__setBlendMode(NORMAL);
			renderer.__worldAlpha = 1 / displayObject.__worldAlpha;

			renderer.__worldTransform.identity();
			renderer.__worldTransform.invert();
			//renderer.__worldTransform.concat(new Matrix());
			renderer.__worldTransform.tx -= offsetX;
			renderer.__worldTransform.ty -= offsetY;

			renderer.__pixelRatio = pixelRatio;

		}
	}

	public function applyFilter(bmp:BitmapData, target:BitmapData, target1:BitmapData, target2:BitmapData, filters:Array<BitmapFilter>, rect:Rectangle, ?mask:BitmapData, ?maskPos:FlxPoint)
	{
		if (mask != null)
		{
			maskShader.relativePos.value[0] = maskPos.x;
			maskShader.relativePos.value[1] = maskPos.y;
			maskShader.mainPalette.input = mask;
			maskFilter.invalidate();
			if (filters == null)
				filters = [maskFilter];
			else
				filters.push(maskFilter);
		}
		renderer.__setBlendMode(NORMAL);
		renderer.__worldAlpha = 1;

		renderer.__worldTransform.identity();
		renderer.__worldColorTransform.__identity();

		var bitmap:BitmapData = target;
		var bitmap2 = target1;

		var bitmap3 = target2;


		bmp.__renderTransform.translate(Math.abs(rect.x), Math.abs(rect.y));
		renderer.__setRenderTarget(bitmap);
		renderer.__renderFilterPass(bmp, renderer.__defaultDisplayShader, true);
		bmp.__renderTransform.identity();

		if (filters != null)
		{
			for (filter in filters)
			{
				if (filter.__preserveObject)
				{
					renderer.__setRenderTarget(bitmap3);
					renderer.__renderFilterPass(bitmap, renderer.__defaultDisplayShader, filter.__smooth);
				}

				for (i in 0...filter.__numShaderPasses)
				{
					renderer.__setBlendMode(filter.__shaderBlendMode);
					renderer.__setRenderTarget(bitmap2);
					renderer.__renderFilterPass(bitmap, filter.__initShader(renderer, i, (filter.__preserveObject) ? bitmap3 : null), filter.__smooth);

					renderer.__setRenderTarget(bitmap);
					renderer.__renderFilterPass(bitmap2, renderer.__defaultDisplayShader, filter.__smooth);
				}

				filter.__renderDirty = false;
			}

			if (mask != null)
				filters.pop();

			var gl = renderer.__gl;

			var renderBuffer = bitmap.getTexture(renderer.__context3D);
			@:privateAccess
			gl.readPixels(0, 0, bitmap.width, bitmap.height, renderBuffer.__format, gl.UNSIGNED_BYTE, bitmap.image.data);
			bitmap.image.version = 0;
			@:privateAccess
			bitmap.__textureVersion = -1;
		}
	}

	public function applyBlend(blend:BlendMode, bitmap:BitmapData)
	{
		bitmap.__update(false, true);
		var bmp = new BitmapData(bitmap.width, bitmap.height, 0);

		#if (js && html5)
		ImageCanvasUtil.convertToCanvas(bmp.image);
		@:privateAccess
		var renderer = new CanvasRenderer(bmp.image.buffer.__srcContext);
		#else
		var renderer = new CairoRenderer(new Cairo(bmp.getSurface()));
		#end

		// setRenderer(renderer, bmp.rect);

		var m = new Matrix();
		var c = new ColorTransform();
		renderer.__allowSmoothing = true;
		renderer.__overrideBlendMode = blend;
		renderer.__worldTransform = m;
		renderer.__worldAlpha = 1;
		renderer.__worldColorTransform = c;

		renderer.__setBlendMode(blend);
		#if (js && html5)
		bmp.__drawCanvas(bitmap, renderer);
		#else
		bmp.__drawCairo(bitmap, renderer);
		#end

		return bitmap;
	}

	public function graphicstoBitmapData(gfx:Graphics, ?target:BitmapData = null) // TODO!: Support for CPU based games (Cairo/Canvas only renderers)
	{
		if (gfx.__bounds == null) return null;

		var cacheRTT = renderer.__context3D.__state.renderToTexture;
		var cacheRTTDepthStencil = renderer.__context3D.__state.renderToTextureDepthStencil;
		var cacheRTTAntiAlias = renderer.__context3D.__state.renderToTextureAntiAlias;
		var cacheRTTSurfaceSelector = renderer.__context3D.__state.renderToTextureSurfaceSelector;

		var bounds = gfx.__owner.getBounds(null);


		var bmp = (target == null) ? new BitmapData(Math.ceil(bounds.width), Math.ceil(bounds.height), true, 0) : target;

		renderer.__worldTransform.translate(-bounds.x, -bounds.y);

		// GfxRenderer.render(gfx, cast renderer.__softwareRenderer);
		// var bmp = gfx.__bitmap;

		var context = renderer.__context3D;

		renderer.__setRenderTarget(bmp);
		context.setRenderToTexture(bmp.getTexture(context));

		Context3DGraphics.render(gfx, renderer);

		renderer.__worldTransform.identity();


		var gl = renderer.__gl;
		var renderBuffer = bmp.getTexture(context);

		@:privateAccess
		gl.readPixels(0, 0, Math.round(bmp.width), Math.round(bmp.height), renderBuffer.__format, gl.UNSIGNED_BYTE, bmp.image.data);


		if (cacheRTT != null)
		{
			renderer.__context3D.setRenderToTexture(cacheRTT, cacheRTTDepthStencil, cacheRTTAntiAlias, cacheRTTSurfaceSelector);
		}
		else
		{
			renderer.__context3D.setRenderToBackBuffer();
		}

		return bmp;
	}
}