package flxanimate.display;

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
class FlxAnimateFilterRenderer
{
    var renderer:OpenGLRenderer;
	var context:Context3D;

    public function new()
    {
		// context = new openfl.display3D.Context3D(null);
        renderer = new OpenGLRenderer(FlxG.game.stage.context3D);

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
			renderer.__worldTransform.concat(new Matrix());
			renderer.__worldTransform.tx -= offsetX;
			renderer.__worldTransform.ty -= offsetY;
			renderer.__worldTransform.scale(pixelRatio, pixelRatio);

			renderer.__pixelRatio = pixelRatio;

		}
	}

	public function applyFilter(bmp:BitmapData, filters:Array<BitmapFilter>, rect:Rectangle)
	{
		if (filters == null || filters.length == 0) return bmp;
		
		renderer.__setBlendMode(NORMAL);
		renderer.__worldAlpha = 1;
		
		if (renderer.__worldTransform == null)
		{
			renderer.__worldTransform = new Matrix();
			renderer.__worldColorTransform = new ColorTransform();
		}

		var bitmap:BitmapData = new BitmapData(Math.ceil(rect.width), Math.ceil(rect.height), true, 0);
		var bitmap2 = bitmap.clone();

		
		var bitmap3 = bitmap2.clone();

		
		bitmap.copyPixels(bmp, bmp.rect, new Point((bitmap.width - bmp.width) * 0.5, (bitmap.height - bmp.height) * 0.5));

		renderer.__setBlendMode(NORMAL);

		renderer.__worldAlpha = 1;
		renderer.__worldTransform.identity();
		renderer.__worldColorTransform.__identity();
		

		var shader, cacheBitmap = null;

		for (filter in filters)
		{
			if (filter.__preserveObject)
			{
				renderer.__setRenderTarget(bitmap3);
				renderer.__renderFilterPass(bitmap, renderer.__defaultDisplayShader, filter.__smooth);
			}

			for (i in 0...filter.__numShaderPasses)
			{
				shader = filter.__initShader(renderer, i, (filter.__preserveObject) ? bitmap3 : null);
				renderer.__setBlendMode(filter.__shaderBlendMode);
				renderer.__setRenderTarget(bitmap2);
				renderer.__renderFilterPass(bitmap, shader, filter.__smooth);

				cacheBitmap = bitmap;
				bitmap = bitmap2;
				bitmap2 = cacheBitmap;
			}
			filter.__renderDirty = false;
		}
		
		bitmap2.dispose();
        bitmap3.dispose();
		if (cacheBitmap != null)
			cacheBitmap.dispose();

		return bitmap;
	}

	public function applyBlend(blend:BlendMode, bitmap:BitmapData)
	{
		var bmp = new BitmapData(bitmap.width, bitmap.height, 0);

		#if (js && html5)
		ImageCanvasUtil.convertToCanvas(bmp.image);
		var renderer = new CanvasRenderer(bmp.image.buffer.__srcContext);
		#else
		var renderer = new CairoRenderer(new Cairo(bmp.getSurface()));
		#end

		setRenderer(renderer, bmp.rect);
		renderer.__setBlendMode(blend);

		#if (js && html5)
		bmp.__drawCanvas(bitmap, renderer);
		#else
		bmp.__drawCairo(bitmap, renderer);
		#end

		return bmp;
	}

    public function graphicstoBitmapData(gfx:Graphics)
    {
		GfxRenderer.render(gfx, cast renderer.__softwareRenderer);
		var bmp = gfx.__bitmap;

		gfx.__bitmap = null;
		gfx.__renderTransform.identity();

        return bmp;
    }
}