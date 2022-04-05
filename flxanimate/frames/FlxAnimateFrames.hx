package flxanimate.frames;
import flxanimate.data.SpriteMapData.Meta;
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
import flixel.system.FlxAssets.FlxGraphicAsset;
#if html5
import lime._internal.backend.html5.HTML5HTTPRequest;
#end
#if haxe4
import haxe.xml.Access;
#else
import haxe.xml.Fast as Access;
#end
#if html5
@:access(lime._internal.backend.html5.HTML5HTTPRequest)
#end
class FlxAnimateFrames
{
    static var data:AnimateAtlas = null;
    static var zip:Null<List<haxe.zip.Entry>>;
    static var thingies:Map<String, FlxAtlasFrames> = new Map();
    /**
     * Parses the spritemaps into small sprites to use in the animation.
     * 
     * @param Path          Where the Sprites are, normally you use it once when calling FlxAnimate already
     * @return              new sliced limbs for you to use ;)
     */
    public static function fromTextureAtlas(Path:String):FlxAtlasFrames
    {
        if (thingies.exists(Path))
            return thingies.get(Path);
        var bitmap:BitmapData = null;
        if (zip != null || haxe.io.Path.extension(Path) == "zip")
        {
            #if html5
            FlxG.log.error("Zip Stuff isn't supported on html5!!!!");
            return null;
            #end
            var imagemap:Map<String, Bytes> = new Map();
            var jsonMap:Map<String, AnimateAtlas> = new Map();
            var thing = (zip != null) ? zip :  Zip.unzip(Zip.readZip(new BytesInput(Assets.getBytes(Path))));
			for (list in thing)
			{
                if (haxe.io.Path.extension(list.fileName) == "json")
                {
                    jsonMap.set(list.fileName,haxe.Json.parse(StringTools.replace(list.data.toString(), String.fromCharCode(0xFEFF), "")));
                }
                else if (haxe.io.Path.extension(list.fileName) == "png")
                {
                    var name = list.fileName.split("/");
                    imagemap.set(name[name.length - 1], list.data);
                }
			}
            // Assuming the json has the same stuff as the image stuff
            for (curJson in jsonMap)
            {
                if (data == null)
                {
                    data = curJson;
                    
                    var curImage = BitmapData.fromBytes(imagemap[data.meta.image]);

                    
                    bitmap = curImage;
                }
                else
                {
                    var data2 = curJson;
                    var size = data.meta.size;
                    var size2 = data2.meta.size;
                    var bitmap2 = BitmapData.fromBytes(imagemap[data.meta.image]);
                    var bitmapDraw = new BitmapData(max(size.w, size2.w), size.h + size2.h, true, 0x00000000);
                    bitmapDraw.draw(bitmap);
                    bitmapDraw.draw(bitmap2, new FlxMatrix(1,0,0,1, 0, size.h));

                    for (e in data2.ATLAS.SPRITES)
                    {
                        e.SPRITE.y += size.h;
                    }
                    data.ATLAS.SPRITES.concat(data2.ATLAS.SPRITES);
                    bitmap = bitmapDraw;
                    data.meta.size.w = bitmap.width;
                    data.meta.size.h = bitmap.height;
                }
            }
            zip == null;
        }
        else
        {
            if (Assets.exists('$Path/spritemap1.json'))
            {
                var i:Int = 1;
                data = haxe.Json.parse(StringTools.replace(Assets.getText('$Path/spritemap1.json'), String.fromCharCode(0xFEFF), ""));
                bitmap = Assets.getBitmapData('$Path/${data.meta.image}');
                while (Assets.exists('$Path/spritemap$i.json'))
                {
                    if (i > 1)
                    {
                        var data2:AnimateAtlas = haxe.Json.parse(StringTools.replace(Assets.getText('$Path/spritemap$i.json'), String.fromCharCode(0xFEFF), ""));

                        for (e in data2.ATLAS.SPRITES)
                        {
                            e.SPRITE.y += data.meta.size.h;
                        }
                        data.ATLAS.SPRITES.concat(data2.ATLAS.SPRITES);

                        var bitmap2 = Assets.getBitmapData('$Path/${data2.meta.image}');
                        
                        var bitmapDraw = new BitmapData(max(data.meta.size.w, data2.meta.size.w), data.meta.size.h + data2.meta.size.h, true, 0x00000000);
                        bitmapDraw.draw(bitmap);
                        bitmapDraw.draw(bitmap2, new FlxMatrix(1,0,0,1, 0, data.meta.size.h));
                        
                        bitmap = bitmapDraw;
                        data.meta.size.w = bitmap.width;
                        data.meta.size.h = bitmap.height;
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
        thingies.set(Path, frames);
        #if html5
        trace("SEXY FRAMES ONLY FOR YA!!!!!!");
        #end
        return frames;
    }
    /**
     * Sparrow spritesheet format parser with support of both of the versions and making the image completely optional to you.
     * @param Path The direction of the Xml you want to parse.
     * @param Image (Optional) the image of the Xml.
     * @return a collection of Frames right from the oven ;)
     */
    public static function fromSparrow(Path:String, ?Image:FlxGraphicAsset):FlxAtlasFrames
	{
        if (!Assets.exists(Path))
			return null;
		var data:Access = new Access(Xml.parse(Assets.getText(Path)).firstElement());
        if (Image == null)
        {
            var splitDir = Path.split("/");
            splitDir.pop();
            splitDir.push(data.att.imagePath);
            Image = splitDir.join("/");
        }
		var graphic:FlxGraphic = FlxG.bitmap.add(Image);
		if (graphic == null)
			return null;

		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		frames = new FlxAtlasFrames(graphic);

		for (texture in data.nodes.SubTexture)
		{
            var version2 = texture.has.width;
			var name = texture.att.name;
			var trimmed = texture.has.frameX;
			var rotated = (texture.has.rotated && texture.att.rotated == "true");
			var flipX = (texture.has.flipX && texture.att.flipX == "true");
			var flipY = (texture.has.flipY && texture.att.flipY == "true");
            
			var rect = FlxRect.get(Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y), Std.parseFloat((version2) ? texture.att.width : texture.att.w),
				Std.parseFloat((version2) ? texture.att.height : texture.att.h));

			var size = (trimmed) ? new FlxRect(Std.parseInt(texture.att.frameX), Std.parseInt(texture.att.frameY), Std.parseInt(texture.att.frameWidth),
					Std.parseInt(texture.att.frameHeight)) : new FlxRect(0, 0, rect.width, rect.height);

			var angle = rotated ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;

			var offset = FlxPoint.get(-size.left, -size.top);
			var ImageSize = FlxPoint.get(size.width, size.height);

			if (rotated && !trimmed)
				ImageSize.set(size.height, size.width);

			frames.addAtlasFrame(rect, ImageSize, offset, name, angle, flipX, flipY);
		}

		return frames;
	}
    /**
     * Json parser which only adds the 'only 1 Path' support
     * @param Path the dir of the Json
     * @param Image (Optional) the Image
     * @return Fresh new Frames to look at ;)
     */
    public static function fromJson(Path:String, ?Image:FlxGraphicAsset):FlxAtlasFrames
    {
        if (!Assets.exists(Path))
            return null;
        if (Image == null)
        {
            var splitDir = Path.split("/");
            splitDir.pop();
            var meta:Meta = haxe.Json.parse(StringTools.replace(Assets.getText(Path), String.fromCharCode(65279), "")).meta;
            splitDir.push(meta.image);
            Image = splitDir.join("/");
        }

        return FlxAtlasFrames.fromTexturePackerJson(Image, Path);
    }
    /**
     * Edge Animate format parser which is basically from Json but with a single extra step lol
     * @param Path the Path of the .eas
     * @param Image (Optional) the Image
     * @return Cute little Frames to use ;)
     */
    public static function fromEdgeAnimate(Path:String, ?Image:FlxGraphicAsset):FlxAtlasFrames
    {
        return fromJson(Path, Image);
    }
    /**
     * Starling spritesheet format parser which uses a preference list from Mac computer shit
     * @param Path the dir of the preference list
     * @param Image (Optional) the Image
     * @return Some recently cooked Frames for you ;)
     */
    public static function fromStarling(Path:String, ?Image:FlxGraphicAsset):FlxAtlasFrames
    {
        if (!Assets.exists(Path))
            return null;
        var data = PropertyList.parse(Assets.getText(Path));
        if (Image == null)
        {
            var splitDir = Path.split("/");
            splitDir.pop();
            splitDir.push(data.metadata.textureFileName);
            Image = splitDir.join("/");
        }

        var graphic:FlxGraphic = FlxG.bitmap.add(Image, false);
		if (graphic == null)
			return null;

		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		frames = new FlxAtlasFrames(graphic);

        for (frameName in Reflect.fields(data.frames))
        {
            starlingHelper(frameName, Reflect.field(data.frames, frameName), frames);
        }

		return frames;
    }
    /**
     * Cocos2D spritesheet format parser, which basically has 2 versions,
     * One is basically Starling (2v) and the other one which is a more fucky and weird (3v)
     * @param Path the Path of the plist
     * @param Image (Optional) the image
     * @return Recently made Frames for your dispose ;)
     */
    public static function fromCocos2D(Path:String, ?Image:FlxGraphicAsset):FlxAtlasFrames
    {
        if (!Assets.exists(Path))
            return null;
        var data = PropertyList.parse(Assets.getText(Path));
        if (data.metadata.format == 2)
        {
            return fromStarling(Path, Image);
        }
        else
        {
            if (Image == null)
            {
                var splitDir = Path.split("/");
                splitDir.pop();
                splitDir.push(data.metadata.target.name);
                Image = splitDir.join("/");
            }
            var graphic:FlxGraphic = FlxG.bitmap.add(Image, false);
            if (graphic == null)
                return null;

            // No need to parse data again
            var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
            if (frames != null)
                return frames;

            frames = new FlxAtlasFrames(graphic);

            for (frameName in Reflect.fields(data.frames))
            {
                cocosHelper(frameName, Reflect.field(data.frames, frameName), frames);
            }

            return frames;
        }
    }

    static function cocosHelper(FrameName:String, FrameData:Dynamic, Frames:FlxAtlasFrames)
    {
        var rotated:Bool = FrameData.textureRotated;
        var name:String = FrameName;
        var sourceSize:FlxPoint = FlxPoint.get(Std.parseFloat(FrameData.spriteSourceSize[0]), Std.parseFloat(FrameData.spriteSourceSize[1]));
        var offset:FlxPoint = FlxPoint.get(-Std.parseFloat(FrameData.spriteOffset[0]), -Std.parseFloat(FrameData.spriteOffset[1]));
        var angle:FlxFrameAngle = FlxFrameAngle.ANGLE_0;
        var frameRect:FlxRect = null;

        var frame = FrameData.textureRect;
        if (rotated)
        {
            frameRect = FlxRect.get(Std.parseFloat(frame[0]), Std.parseFloat(frame[1]), Std.parseFloat(frame[3]), Std.parseFloat(frame[2]));
            angle = FlxFrameAngle.ANGLE_NEG_90;
        }
        else
        {
            frameRect = FlxRect.get(Std.parseFloat(frame[0]), Std.parseFloat(frame[1]), Std.parseFloat(frame[2]), Std.parseFloat(frame[3]));
        }

        Frames.addAtlasFrame(frameRect, sourceSize, offset, name, angle);
    }
    static function starlingHelper(FrameName:String, FrameData:Dynamic, Frames:FlxAtlasFrames):Void
    {
        var rotated:Bool = FrameData.rotated;
        var name:String = FrameName;
        var sourceSize:FlxPoint = FlxPoint.get(Std.parseFloat(FrameData.sourceSize[0]), Std.parseFloat(FrameData.sourceSize[1]));
        var offset:FlxPoint = FlxPoint.get(-Std.parseFloat(FrameData.offset[0]), -Std.parseFloat(FrameData.offset[1]));
        var angle:FlxFrameAngle = FlxFrameAngle.ANGLE_0;
        var frameRect:FlxRect = null;

        var frame = FrameData.frame;
        if (rotated)
        {
            frameRect = FlxRect.get(Std.parseFloat(frame[0]), Std.parseFloat(frame[1]), Std.parseFloat(frame[3]), Std.parseFloat(frame[2]));
            angle = FlxFrameAngle.ANGLE_NEG_90;
        }
        else
        {
            frameRect = FlxRect.get(Std.parseFloat(frame[0]), Std.parseFloat(frame[1]), Std.parseFloat(frame[2]), Std.parseFloat(frame[3]));
        }

        Frames.addAtlasFrame(frameRect, sourceSize, offset, name, angle);
    }
    static function textureAtlasHelper(FrameName:String, FrameData:AnimateSpriteData, Frames:FlxAtlasFrames):Void
    {
        var rotated:Bool = FrameData.rotated;
        var name:String = FrameName;
        var angle:FlxFrameAngle = (rotated) ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;
        var frameRect:FlxRect = FlxRect.get(FrameData.x, FrameData.y, FrameData.w, FrameData.h);
        var ImageSize:FlxPoint = FlxPoint.get(frameRect.width / Std.parseInt(data.meta.resolution), frameRect.height / Std.parseInt(data.meta.resolution));
        
        var offset:FlxPoint = FlxPoint.get(0, 0);
        
        Frames.addAtlasFrame(frameRect, ImageSize, offset, name, angle);
    }
    static function max(a:Int, b:Int):Int
		return a < b ? b : a;
}
// code made by noonat 11 years ago, not mine lol
class PropertyList 
{
    static var _dateRegex:EReg = ~/(\d{4}-\d{2}-\d{2})(?:T(\d{2}:\d{2}:\d{2})Z)?/;

    /**
     * Parse an Apple property list XML file into a dynamic object. If
     * the property list is empty, an empty object will be returned.
     * @param text Text contents of the property list file.
     */
    static public function parse(text:String):Dynamic 
    {
        var fast = new Access(Xml.parse(text).firstElement());
        return fast.hasNode.dict ? parseDict(fast.node.dict) : {};
    }

    static function parseDate(text:String):Date 
    {
        if (!_dateRegex.match(text)) 
        {
            throw 'Invalid date "' + text + '" (only yyyy-mm-dd and yyyy-mm-ddThh:mm:ssZ supported)';
        }
        text = _dateRegex.matched(1);
        if (_dateRegex.matched(2) != null) 
        {
            text += ' ' + _dateRegex.matched(2);
        }
        return Date.fromString(text);
    }

    static function parseDict(node:Access):Dynamic
    {
        var key:String = null;
        var result:Dynamic = {};
        for (childNode in node.elements) 
        {
            if (childNode.name == 'key') 
            {
                key = childNode.innerData;
            } else if (key != null) 
            {
                Reflect.setField(result, key, parseValue(childNode));
            }
        }
        return result;
    }

    static function parseValue(node:Access):Dynamic 
    {
        var value:Dynamic = null;
        switch (node.name) 
        {
            case 'array':
            value = new Array<Dynamic>();
            for (childNode in node.elements) 
            {
                value.push(parseValue(childNode));
            }
            
            case 'dict':
            value = parseDict(node);
            
            case 'date':
            value = parseDate(node.innerData);
            
            case 'string':
            var thing:Dynamic = node.innerData;
            if (thing.charAt(0) == "{")
            {
                thing = StringTools.replace(thing, "{", "");
                thing = StringTools.replace(thing, "}", "");
                thing = thing.split(",");
            }
            value = thing;
            case 'data':
            value = node.innerData;
            
            case 'true':
            value = true;
            
            case 'false':
            value = false;
            
            case 'real':
            value = Std.parseFloat(node.innerData);
            
            case 'integer':
            value = Std.parseInt(node.innerData);
        }
        return value;
    }
}