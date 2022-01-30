package flxAnimate.animate;

import flxAnimate.data.AnimationData.Parsed;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxRect;
import haxe.Json;
import openfl.geom.Rectangle;
import openfl.utils.Assets;
import haxe.ds.IntMap;
import flixel.FlxG;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.group.FlxSpriteGroup;
import flxAnimate.data.SpriteMapData;

using StringTools;

class FlxSpriteMap extends FlxSprite
{
	var nestedShit:IntMap<FlxAnim> = new IntMap<FlxAnim>();
	var frameTickTypeShit:Float;
	var playingAnim:Bool;
	public var framerate:Float;
	public var anim:FlxAnim;
	
	public var animationJSON:Parsed;
	public var spritesJSON:AnimateAtlas;

	public function new(X:Float, Y:Float, Anim:String, ?Framerate:Float = null)
	{
		var jsontxt = Assets.getText(Paths.file('images/$Anim/Animation.json'));
		anim = new FlxAnim(X,Y, Json.parse(jsontxt));
		var spritesjsontxt = Assets.getText(Paths.file('images/$Anim/spritemap1.json'));
		animationJSON = anim.coolParse;

		anim.antialiasing = antialiasing;
		anim.coolParse.AN.TL.L.reverse();
		if (Reflect.hasField(anim.coolParse, "SD"))
		{
			for (e in anim.coolParse.SD.S)
			{
				e.TL.L.reverse();
			}
		}
		spritesJSON = Json.parse(StringTools.replace(spritesjsontxt, String.fromCharCode(0xFEFF), ""));

		if (Framerate != null)
			framerate = Framerate;
		else
			framerate = animationJSON.MD.FRT;
		super(X, Y);

		anim.frames = fromAnimate(Paths.image('$Anim/${spritesJSON.meta.image}'), spritesJSON);
	}

	function fromAnimate(rawImg:String, json:AnimateAtlas):FlxAtlasFrames
	{
		if (rawImg == null || json == null)
			return null;
		var bitmapImg:FlxGraphic = FlxG.bitmap.add(rawImg);
		
		var bitmapResult:FlxAtlasFrames = new FlxAtlasFrames(bitmapImg);

        for (i in json.ATLAS.SPRITES)
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
	public override function draw()
	{
		super.draw();
		anim.renderFrames();
	}

	public function playAnim(reverse:Bool = false)
	{
		playingAnim = true;
	}

	public function stopAnim()
	{
		playingAnim = false;
	}

	public override function update(elapsed:Float)
	{
		anim.x = x;
		anim.y = y;
		super.update(elapsed);
		
		if (playingAnim)
		{
			frameTickTypeShit += elapsed;
			
			if (frameTickTypeShit >= 1 / framerate)
			{
				anim.curFrame += 1;
				frameTickTypeShit = 0;
			}
		}

		if (FlxG.keys.justPressed.RIGHT || FlxG.mouse.wheel > 0)
			anim.curFrame += 1;
		if (FlxG.keys.justPressed.LEFT || FlxG.mouse.wheel < 0)
			anim.curFrame -= 1;
	}
}
