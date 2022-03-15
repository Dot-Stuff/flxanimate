package flxanimate.animate;

import haxe.io.Bytes;
import flxanimate.zip.Zip;
import haxe.io.BytesInput;
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

class FlxSpriteMap
{
    static var data:AnimateAtlas = null;
    /**
     * Parses the spritemaps into small sprites to use in the animation.
     * 
     * @param Path          Where the Sprites are, normally you use it once when calling FlxAnimate already
     * @return              A new `FlxAnimateFrames` has been created.
     */
    public static function fromAnimate(Path:String):FlxAtlasFrames
    {
        var bitmap:BitmapData = null;
        if (haxe.io.Path.extension(Path) == "zip")
        {
            var imagemap:Map<String, Bytes> = new Map();
            var json:Array<AnimateAtlas> = [];
            var thing = Zip.readZip(new BytesInput(Assets.getBytes(Path)));
			for (list in Zip.unzip(thing))
			{
                if (!(list.fileName.indexOf("Animation.json") != -1))
                {
                    if (haxe.io.Path.extension(list.fileName) == "json")
                    {
                        json.push(haxe.Json.parse(StringTools.replace(list.data.toString(), String.fromCharCode(0xFEFF), "")));
                    }
                    else if (haxe.io.Path.extension(list.fileName) == "png")
                    {
                        var name = list.fileName.split("/");
                        imagemap.set(name[name.length - 1], list.data);
                    }
                }
			}
            // Assuming the json has the same stuff as the image stuff
            for (num in 0...json.length)
            {
                var curJson = json[num];
                if (data == null)
                {
                    data = curJson;
                    bitmap = BitmapData.fromBytes(imagemap[data.meta.image]);
                }
                else
                {
                    var data2 = curJson;
                    var bitmap2 = BitmapData.fromBytes(imagemap[data2.meta.image]);
                    var bitmapDraw = new BitmapData(max(bitmap.width, bitmap2.width), bitmap.height + bitmap2.height, true, 0x00000000);
                    bitmapDraw.draw(bitmap);
                    bitmapDraw.draw(bitmap2, new FlxMatrix(1,0,0,1, 0, bitmap.height));
                    for (e in data2.ATLAS.SPRITES)
                    {
                        e.SPRITE.y += bitmap.height;
                        data.ATLAS.SPRITES.push(e);
                    }
                    bitmap = bitmapDraw;
                }
            }
        }
        else
        {
            if (Assets.exists('$Path/spritemap1.json'))
            {
                data = haxe.Json.parse(StringTools.replace(Assets.getText('$Path/spritemap1.json'), String.fromCharCode(0xFEFF), ""));
                var i:Int = 1;
                bitmap = Assets.getBitmapData('$Path/${data.meta.image}');
                while (Assets.exists('$Path/spritemap$i.json'))
                {
                    if (i > 1)
                    {
                        var data2:AnimateAtlas = haxe.Json.parse(StringTools.replace(Assets.getText('$Path/spritemap$i.json'), String.fromCharCode(0xFEFF), ""));

                        for (e in data2.ATLAS.SPRITES)
                        {
                            e.SPRITE.y += bitmap.height;
                            data.ATLAS.SPRITES.push(e);
                        }

                        var bitmap2 = Assets.getBitmapData('$Path/${data.meta.image}');
                        
                        var bitmapDraw = new BitmapData(max(bitmap.width, bitmap2.width), bitmap.height + bitmap2.height, true, 0x00000000);
                        bitmapDraw.draw(bitmap);
                        bitmapDraw.draw(bitmap2, new FlxMatrix(1,0,0,1, 0, bitmap.height));
                        
                        bitmap = bitmapDraw;   
                    }
                    i++;
                }
            }
            else if (Assets.exists('$Path/spritemap.json'))
            {
                data = haxe.Json.parse(StringTools.replace(Assets.getText('$Path/spritemap.json'), String.fromCharCode(0xFEFF), ""));
                bitmap = Assets.getBitmapData('$Path/${data.meta.image}');
            }
        }

        if (data == null)
        {
            FlxG.log.warn('No Spritemap json data in $Path!');
            return null;
        }
        if (bitmap == null)
        {
            FlxG.log.warn('No Spritemap image in $Path!');
            return null;
        }
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
        var frameRect:FlxRect = FlxRect.get(FrameData.x, FrameData.y, FrameData.w, FrameData.h);
        var sourceSize:FlxPoint = FlxPoint.get(frameRect.width / Std.parseInt(data.meta.resolution), frameRect.height / Std.parseInt(data.meta.resolution));
        
        var offset:FlxPoint = FlxPoint.get(0, 0);
        
        Frames.addAtlasFrame(frameRect, sourceSize, offset, name, angle);
    }
    static function max(a:Int, b:Int):Int
		return a < b ? b : a;
}
