package flxanimate.frames;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import openfl.geom.Rectangle;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flxanimate.data.SpriteMapData;
import flxanimate.format.PropertyList;
import openfl.Assets;
import haxe.xml.Access;

class FlxAnimateFrames extends FlxAtlasFrames
{
	public function new()
	{
		super(null);
		parents = [];
	}

	static var data:AnimateAtlas = null;
	static var zip:Null<List<haxe.zip.Entry>>;

	public var parents:Array<FlxGraphic>;

	/**
	 * Helper function to parse several Spritemaps from a texture atlas via `fromSpritemap()`
	 *
	 * @param Path          The Path of the directory.
	 * @return              a new instance of `FlxAnimateFrames`.
	 * @see `fromSpriteMap()`
	 */
	public static function fromTextureAtlas(Path:String):FlxAnimateFrames
	{
		var frames:FlxAnimateFrames = new FlxAnimateFrames();

		var texts = Assets.list(TEXT).filter((text) -> StringTools.startsWith(text, '$Path/sprite'));

		var texts = [];
		var isDone = false;

		if (Assets.exists('$Path/spritemap.json'))
		{
			texts.push('$Path/spritemap.json');
			isDone = true;
		}

		var i = 1;
		while (!isDone)
		{
			if (Assets.exists('$Path/spritemap$i.json'))
				texts.push('$Path/spritemap$i.json');

			else
				isDone = true;

			i++;
		}

		for (text in texts)
		{
			var spritemapFrames = fromSpriteMap(text);

			if (spritemapFrames != null)
				frames.addAtlas(spritemapFrames);
		}

		if (frames.frames == [])
		{
			FlxG.log.error("the Frames parsing couldn't parse any of the frames, it's completely empty! \n Maybe you misspelled the Path?");
			return null;
		}

		return frames;
	}

	/**
	 * Parses a spritemap, proceeding from a texture atlas export.
	 * @param Path
	 * @param Image
	 * @return FlxAtlasFrames
	 */
	public static function fromSpriteMap(Path:FlxSpriteMap, ?Image:FlxGraphicAsset):FlxAtlasFrames
	{
		if (Path == null)
			return null;

		var json:AnimateAtlas = null;

		if (Path is String)
		{
			var str:String = cast (Path, String).split("\\").join("/");
			var text = (StringTools.contains(str, "/")) ? Assets.getText(str) : str;
			json = haxe.Json.parse(text.split(String.fromCharCode(0xFEFF)).join(""));
		}
		else
			json = Path;


		if (json == null)
			return null;

		if (Image == null)
		{
			if (Path is String)
			{
				Image = haxe.io.Path.addTrailingSlash(haxe.io.Path.directory(Path)) + json.meta.image;
			}
			else
				return null;
		}

		var graphic:FlxGraphic = FlxG.bitmap.add(Image);
		if (graphic == null)
			return null;

		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		frames = new FlxAtlasFrames(graphic);

		for (sprite in json.ATLAS.SPRITES)
		{
			var limb = sprite.SPRITE;
			var rect = FlxRect.get(limb.x, limb.y, limb.w, limb.h);
			if (limb.rotated)
				rect.setSize(rect.height, rect.width);

			sliceFrame(limb.name, limb.rotated, rect, frames);
		}


		return frames;
	}

	#if (flixel < "5.4.0")
	public function addAtlas(collection:FlxFramesCollection, overwriteHash:Bool = false):FlxAtlasFrames
	{
		if (collection.parent == null)
			throw "Cannot add atlas with null parent";

		if (parents.indexOf(collection.parent) == -1)
			parents.push(collection.parent);
		for (frame in collection.frames)
			pushFrame(frame);
		return this;
	}
	#end

	/**
	 * a `Sparrow` spritesheet enhancer, providing for the 'add only the XML Path' workflow while adding support to Sparrow v1.
	 * @param Path The direction of the Xml you want to parse.
	 * @param Image (Optional) the image of the Xml.
	 * @return A new instance of `FlxAtlasFrames`
	 */
	public static function fromSparrow(Path:FlxSparrow, ?Image:FlxGraphicAsset):FlxAtlasFrames
	{
		if (Path is String && !Assets.exists(Path))
			return null;

		var data:Xml = (Path is String) ? Xml.parse(Assets.getText(Path)).firstElement() : Path.firstElement();
		if (Image == null)
		{
			if (Path is String)
				Image = haxe.io.Path.addTrailingSlash(haxe.io.Path.directory(Path)) + data.get("imagePath");
			else
				return null;
		}

		for(node in data.elements()) {
			if(node.nodeName == "SubTexture") {
				if(node.exists("w")) {
					node.set("width", node.get("w"));
					node.remove("w");
				}
				if(node.exists("h")) {
					node.set("height", node.get("h"));
					node.remove("h");
				}
			}
		}

		//var realData = data.toString();
		//if (realData.split("w=\"").length > 1)
		//{
		//	realData.split("w=\"").join("width=\"");
		//	realData.split("h=\"").join("height=\"");
		//}

		return fromSparrowDirect(Image, data);
	}

	public static function fromSparrowDirect(source:FlxGraphicAsset, xml:Xml):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source);
		if (graphic == null)
			return null;
		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		if (xml == null)
			return null;

		frames = new FlxAtlasFrames(graphic);

		var data:Access = new Access(xml);

		for (texture in data.nodes.SubTexture)
		{
			var name = texture.att.name;
			var trimmed = texture.has.frameX;
			var rotated = (texture.has.rotated && texture.att.rotated == "true");
			var flipX = (texture.has.flipX && texture.att.flipX == "true");
			var flipY = (texture.has.flipY && texture.att.flipY == "true");

			var rect = FlxRect.get(Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y), Std.parseFloat(texture.att.width),
				Std.parseFloat(texture.att.height));

			var size = if (trimmed)
			{
				new Rectangle(Std.parseInt(texture.att.frameX), Std.parseInt(texture.att.frameY), Std.parseInt(texture.att.frameWidth),
					Std.parseInt(texture.att.frameHeight));
			}
			else
			{
				new Rectangle(0, 0, rect.width, rect.height);
			}

			var angle = rotated ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;

			var offset = FlxPoint.get(-size.left, -size.top);
			var sourceSize = FlxPoint.get(size.width, size.height);

			if (rotated && !trimmed)
				sourceSize.set(size.height, size.width);

			frames.addAtlasFrame(rect, sourceSize, offset, name, angle, flipX, flipY);
		}

		return frames;
	}

	/**
	 *
	 * @param Path the Json in specific, can be the path of it or the actual json
	 * @param Image the image which the file is referencing **WARNING:** if you set the path as a json, it's obligatory to set the image!
	 * @return A new instance of `FlxAtlasFrames`
	 */
	public static function fromJson(Path:FlxJson, ?Image:FlxGraphicAsset):FlxAtlasFrames
	{
		if (Path is String && !Assets.exists(Path))
			return null;
		var data:JsonNormal = (Path is String) ? haxe.Json.parse(Assets.getText(Path)) : Path;
		if (Image == null)
		{
			if (Path is String)
				Image = haxe.io.Path.addTrailingSlash(haxe.io.Path.directory(Path)) + data.meta.image;
			else
				return null;
		}

		return FlxAtlasFrames.fromTexturePackerJson(Image, data);
	}

	/**
	 * Edge Animate
	 * @param Path the Path of the .eas
	 * @param Image (Optional) the Image
	 * @return Cute little Frames to use ;)
	 */
	public static inline function fromEdgeAnimate(Path:String, ?Image:FlxGraphicAsset):FlxAtlasFrames
	{
		return fromJson((StringTools.startsWith(Path, "{")) ? haxe.Json.parse(Path) : Path, Image);
	}

	/**
	 * Starling spritesheet format parser which uses a preference list from Mac computer shit
	 * @param Path the dir of the preference list
	 * @param Image (Optional) the Image
	 * @return Some recently cooked Frames for you ;)
	 */
	public static function fromStarling(Path:FlxPropertyList, ?Image:FlxGraphicAsset):FlxAtlasFrames
	{
		if (Path is String && !Assets.exists(Path))
			return null;
		var data:Plist = (Path is String) ? PropertyList.parse(Assets.getText(Path)) : Path;
		if (Image == null)
		{
			if (Path is String)
				Image = haxe.io.Path.addTrailingSlash(haxe.io.Path.directory(Path)) + data.metadata.textureFileName;
			else
				return null;
		}

		var graphic:FlxGraphic = FlxG.bitmap.add(Image, false);
		if (graphic == null)
			return null;

		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		frames = new FlxAtlasFrames(graphic);

		for (name in Reflect.fields(data.frames))
		{
			var data = Reflect.field(data.frames, name);

			var dimensions = FlxRect.get(Std.parseFloat(data.frame[0]), Std.parseFloat(data.frame[1]), Std.parseFloat(data.frame[2]),
			Std.parseFloat(data.frame[3]));

			var sourceSize = FlxPoint.get(Std.parseFloat(data.sourceSize[0]), Std.parseFloat(data.sourceSize[1]));

			var offset = FlxPoint.get(Std.parseFloat(data.offset[0]), Std.parseFloat(data.offset[1]));

			sliceFrame(name, data.rotated, dimensions, sourceSize, offset, frames);
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
		var data:Plist = PropertyList.parse(Assets.getText(Path));
		if (data.metadata.format == 2)
		{
			return fromStarling(Path, Image);
		}
		else
		{
			if (Image == null)
			{
				if (Path is String)
					Image = haxe.io.Path.addTrailingSlash(haxe.io.Path.directory(Path)) + data.metadata.target.name;
				else
					return null;
			}
			var graphic:FlxGraphic = FlxG.bitmap.add(Image);
			if (graphic == null)
				return null;

			// No need to parse data again
			var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
			if (frames != null)
				return frames;

			frames = new FlxAtlasFrames(graphic);

			for (name in Reflect.fields(data.frames))
			{
				var data = Reflect.field(data.frames, name);

				var dimensions = FlxRect.get(Std.parseFloat(data.frame[0]), Std.parseFloat(data.frame[1]), Std.parseFloat(data.frame[2]),
				Std.parseFloat(data.frame[3]));

				var sourceSize = FlxPoint.get(Std.parseFloat(data.spriteSourceSize[0]), Std.parseFloat(data.spriteSourceSize[1]));

				var offset = FlxPoint.get(Std.parseFloat(data.spriteOffset[0]), Std.parseFloat(data.spriteOffset[1]));

				sliceFrame(name, data.textureRotated, dimensions, sourceSize, offset, frames);
			}

			return frames;
		}
	}

	/**
	 * EaselJS spritesheet format parser, pretty weird stuff.
	 * @param Path The Path of the jsFile
	 * @param Image (optional) the Path of the image
	 * @return New frames made for you to use ;)
	 */
	public static function fromEaselJS(Path:String, ?Image:FlxGraphicAsset):FlxAnimateFrames
	{
		var hugeFrames:FlxAnimateFrames = new FlxAnimateFrames();
		var separatedJS = Assets.getText(Path).split("\n");
		var lines:Array<String> = [];
		for (line in separatedJS)
		{
			if (StringTools.contains(line, "new createjs.SpriteSheet({"))
				lines.push(line);
		}
		var names:Array<String> = [];
		var jsons:Array<JSJson> = [];
		for (line in lines)
		{
			names.push(StringTools.replace(line.split(".")[0], "_", " "));
			var curJson = StringTools.replace(StringTools.replace(line.split("(")[1], ")", ""), ";", "");
			var parsedJson = haxe.Json.parse(~/({|,\s*)(\S+)(\s*:)/g.replace(curJson, '$1\"$2"$3'));
			jsons.push(parsedJson);
		}
		var prevName = "";
		var imagePath = Path.split("/");
		imagePath.pop();
		for (i in 0...names.length)
		{
			var times = 0;
			var name = names[i];
			var json = jsons[i];
			var bitmap = FlxG.bitmap.add(Assets.getBitmapData((Image == null) ? '${imagePath.join("/")}/${json.images[0]}' : Image));
			var frames = new FlxAtlasFrames(bitmap);
			var initialFrame = [json.frames[0][5], json.frames[0][6]];
			for (frame in json.frames)
			{
				sliceFrame(name, false, FlxRect.get(frame[0], frame[1], frame[2], frame[3]), null,
				FlxPoint.get(frame[5] - initialFrame[0], frame[6] - initialFrame[1]), frames);
				times++;
			}
			hugeFrames.addAtlas(frames);
		}
		return hugeFrames;
	}

	public static function sliceFrame(name:String, rotated:Bool, dimensions:FlxRect, ?sourceSize:FlxPoint, ?offset:FlxPoint, Frames:FlxAtlasFrames)
	{
		if (rotated)
			dimensions.setSize(dimensions.height, dimensions.width);

		Frames.addAtlasFrame(dimensions, (sourceSize != null) ? sourceSize : FlxPoint.get(dimensions.x, dimensions.y),
			(offset != null) ? offset.negate() : FlxPoint.get(), name, (rotated) ? ANGLE_NEG_90 : ANGLE_0);
	}
}