package flxanimate;

import flixel.math.FlxMatrix;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flxanimate.data.SpriteMapData.AnimateAtlas;
import flxanimate.data.SpriteMapData.AnimateSpriteData;
import openfl.Assets;
import openfl.display.BitmapData;
import flxanimate.data.AnimationData;

class FlxAnimateFrames extends FlxAtlasFrames
{
	static var data:AnimateAtlas = null;

	/**
	 * Parsing method for Animate Texture Atlases
	 * 
	 * @param Path          Set the Path where the Sprites are.
	 * @return              Newly created `FlxAtlasFrames` collection.
	 */
	public static function fromAnimate(Path:String):FlxAtlasFrames
	{
		var bitmap:BitmapData = null;
		if (Assets.exists('$Path/spritemap1.json'))
		{
			data = haxe.Json.parse(StringTools.replace(Assets.getText('$Path/spritemap1.json'), String.fromCharCode(0xFEFF), ""));
		}
		else if (Assets.exists('$Path/spritemap.json'))
		{
			data = haxe.Json.parse(StringTools.replace(Assets.getText('$Path/spritemap.json'), String.fromCharCode(0xFEFF), ""));
		}

		if (data == null)
			return null;
		if (Assets.exists('$Path/spritemap1.png'))
		{
			var i:Int = 1;
			bitmap = Assets.getBitmapData('$Path/spritemap1.png');
			while (Assets.exists('$Path/spritemap$i.png'))
			{
				if (i > 1)
				{
					var data2:AnimateAtlas = haxe.Json.parse(StringTools.replace(Assets.getText('$Path/spritemap$i.json'), String.fromCharCode(0xFEFF), ""));

					for (e in data2.ATLAS.SPRITES)
					{
						e.SPRITE.y += bitmap.height;
						data.ATLAS.SPRITES.push(e);
					}

					var bitmap2 = Assets.getBitmapData('$Path/spritemap$i.png');
					var bitmapDraw = new BitmapData(bitmap.width + bitmap2.width, max(bitmap.height, bitmap2.height), true, 0x00000000);
					bitmapDraw.draw(bitmap);
					bitmapDraw.draw(bitmap2, new FlxMatrix(1, 0, 0, 1, bitmap.width, 0));

					bitmap = bitmapDraw;
				}
				i++;
			}
		}
		else if (Assets.exists('$Path/spritemap.png'))
		{
			bitmap = Assets.getBitmapData('$Path/spritemap.png');
		}

		if (bitmap == null)
			return null;
		AnimationData.version = data.meta.version;
		var graphic:FlxGraphic = FlxG.bitmap.add(bitmap);

		var frames:FlxAtlasFrames = new FlxAtlasFrames(graphic);

		for (sprites in data.ATLAS.SPRITES)
		{
			textureAtlasHelper(sprites.SPRITE.name, sprites.SPRITE, frames);
		}

		return frames;
	}

	static function textureAtlasHelper(FrameName:String, FrameData:AnimateSpriteData, Frames:FlxAtlasFrames):Void
	{
		var rotated:Bool = FrameData.rotated;
		var name:String = FrameName;
		var angle:FlxFrameAngle = (rotated) ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;
		var frameRect:FlxRect = (rotated) ? FlxRect.get(FrameData.x, FrameData.y, FrameData.h,
			FrameData.w) : FlxRect.get(FrameData.x, FrameData.y, FrameData.w, FrameData.h);
		var sourceSize:FlxPoint = FlxPoint.get(frameRect.width / Std.parseInt(data.meta.resolution), frameRect.height / Std.parseInt(data.meta.resolution));

		var offset:FlxPoint = FlxPoint.get(0, 0);

		Frames.addAtlasFrame(frameRect, sourceSize, offset, name, angle);
	}

	// adding a max for Int stuff
	static function max(a:Int, b:Int):Int
		return a < b ? b : a;
}
