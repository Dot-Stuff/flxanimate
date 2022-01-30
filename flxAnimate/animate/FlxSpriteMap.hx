package flxanimate.animate;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import haxe.Json;
import flixel.FlxG;
import openfl.Assets;
import openfl.geom.Rectangle;
import flxAnimate.data.SpriteMapData;

using StringTools;

class FlxAnimate
{
	/**
	 * Parsing method for Animate texture atlases
	 * 
	 * @param Source 		  The image source (can be `FlxGraphic`, `String` or `BitmapData`).
	 * @param Description	  Contents of the JSON file with atlas description.
	 *                        You can get it with `Assets.getText(path/to/description.json)`.
	 *                        Or you can just pass a path to the JSON file in the assets directory.
	 * @return  Newly created `FlxAtlasFrames` collection.
	 */
	public static function fromAnimate(Source:FlxGraphicAsset, Description:String):FlxAtlasFrames
	{
		if (Source == null || Description == null)
			return null;
		var graphic:FlxGraphic = FlxG.bitmap.add(Source);

		var frames = new FlxAtlasFrames(graphic);

		trace(Description);
		if (Assets.exists(Description))
			Description = Assets.getText(Description);

		var data:AnimateAtlas = Json.parse(Description);

		for (sprites in data.ATLAS.SPRITES)
		{
			var name = sprites.SPRITE.name;
			var rotated = sprites.SPRITE.rotated;

			var rect:FlxRect = FlxRect.get(sprites.SPRITE.x, sprites.SPRITE.y, sprites.SPRITE.w, sprites.SPRITE.h);
			var size:Rectangle = new Rectangle(0, 0, rect.width, rect.height);

			var angle = rotated ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;

			var offset = FlxPoint.get(-size.left, -size.top);
			var sourceSize = FlxPoint.get(size.width, size.height);

			frames.addAtlasFrame(rect, sourceSize, offset, name, angle);
		}

		return frames;
	}
}
