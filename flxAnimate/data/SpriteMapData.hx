package flxanimate.data;

typedef AnimateAtlas = {
    var ATLAS:AnimateSprites;
	var meta:MetaStuff;
};

typedef AnimateSprites = {
    var SPRITES:Array<AnimateSprite>;
};

typedef AnimateSprite = {
    var SPRITE:AnimateSpriteData;
};

typedef MetaStuff = {
	var app:String;
	var version:String;
	var image:String;
	var format:String;
	var size:SizeMeta;
	var resolution:String;
}

typedef SizeMeta = 
{
	var w:Float;
	var h:Float;
}
typedef AnimateSpriteData = {
    var name:String;
    var x:Float;
    var y:Float;
    var w:Float;
    var h:Float;
	var rotated:Bool;
};
