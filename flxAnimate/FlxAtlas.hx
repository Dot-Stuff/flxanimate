package flxAnimate;

class FlxAtlas extends flxanimate.animate.FlxAnim
{
    /**
     * Testing
     * @param x 
     * @param y 
     * @param path 
     */
    public function new(x:Float, y:Float, path:String)
    {
        coolParse = haxe.Json.parse(path);
		coolParse.AN.TL.L.reverse();

		super(x, y, coolParse);

        frames = flxanimate.animate.FlxSpriteMap.fromAnimate('$path/spritemap1.png', '$path/spritemap1.json');
    }

    var frameTickTypeShit:Float;
    public var playingAnim:Bool = false;

    public override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (playingAnim)
        {
            frameTickTypeShit += elapsed;

            if (frameTickTypeShit >= 1 / coolParse.MD.FRT)
            {
                changeFrame(1);
                frameTickTypeShit = 0;
            }
        }
    }
}
