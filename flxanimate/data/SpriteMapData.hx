package flxanimate.data;

import flxanimate.data.AnimationData.OneOfTwo;

typedef AnimateAtlas =
{
	var ATLAS:AnimateSprites;
	var meta:Meta;
}

typedef AnimateSprites =
{
	var SPRITES:Array<AnimateSprite>;
}

typedef AnimateSprite =
{
	var SPRITE:AnimateSpriteData;
}

typedef AnimateSpriteData =
{
	var name:String;
	var x:Float;
	var y:Float;
	var w:Int;
	var h:Int;
	var rotated:Bool;
}
@:forward
abstract Meta({var app:String; var version:String; var image:String; var format:String; var size:Size;})
{
	public var resolution(get, never):String;

	inline function get_resolution()
	{
		return AnimationData.setFieldBool(this, ["resolution", "scale"]);
	}
}

// Unrelated to Spritemap, but different spritesheet formats that Adobe Animate supports o
typedef Size =
{
	var w:Int;
	var h:Int;
}

typedef JSJson =
{
	var images:Array<String>;
	var frames:Array<Array<Int>>;
}

typedef FlxSpriteMap = OneOfTwo<String, AnimateAtlas>;
typedef FlxSparrow = OneOfTwo<String, Xml>;
typedef FlxJson = OneOfTwo<String, JsonNormal>;
typedef FlxPropertyList = OneOfTwo<String, Plist>;

typedef JsonNormal =
{
	frames:Dynamic,
	meta:Meta
}

typedef Plist =
{
	frames:Dynamic,
	metadata:Dynamic
}
