package flxanimate;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flxanimate.data.SpriteMapData.AnimateAtlas;
import flxanimate.data.SpriteMapData.AnimateSpriteData;
import openfl.Assets;
import openfl.geom.Rectangle;

class FlxAnimateFrames
{
    /**
     * Parsing method for Animate Texture Atlases
     * 
     * @param Source        The image source (can be `FlxGraphic`, `String` or `BitmapData`).
     * @param Description   Contents of the JSON file with atlas description.
	 *                      You can get it with `Assets.getText(path/to/description.json)`.
	 *                      Or you can just pass a path to the JSON file in the assets directory.
     * @return              Newly created `FlxAtlasFrames` collection.
     */
    public static function fromAnimate(Source:FlxGraphicAsset, Description:String):FlxAtlasFrames
    {
        var graphic:FlxGraphic = FlxG.bitmap.add(Source);
        if (graphic == null)
            return null;

        var bitmapResult:FlxAtlasFrames = new FlxAtlasFrames(graphic);

        if (Assets.exists(Description))
            Description = Assets.getText(Description);

        var data:AnimateAtlas = haxe.Json.parse(StringTools.replace(Description, String.fromCharCode(0xFEFF), ""));

        for (i in data.ATLAS.SPRITES)
        {
            var data:AnimateSpriteData = i.SPRITE;
            var frame:FlxRect = FlxRect.get(data.x, data.y, data.w, data.h);
            var rectangleSize:Rectangle = new Rectangle(0, 0, frame.width, frame.height);

            var offset:FlxPoint = FlxPoint.get(-rectangleSize.left, -rectangleSize.top);
            var angle = data.rotated ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;
            var sourceSize:FlxPoint = FlxPoint.get(rectangleSize.width, rectangleSize.height);
            bitmapResult.addAtlasFrame(frame, sourceSize, offset, data.name, angle);
        }

        return bitmapResult;
    }
}