package;

import flxanimate.FlxSpriteMap;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flxanimate.FlxAnimateFrames;
import flixel.FlxG;

class PlayState extends FlxState
{
	var char:FlxSpriteMap;

	override public function create()
	{
		var bg = FlxGridOverlay.create(10, 10, FlxG.width * 4, FlxG.height * 4);
		bg.scrollFactor.set(0.5, 0.5);
		bg.screenCenter();
		add(bg);

		var charPath = 'assets/images/picoShoot';
		char = new FlxSpriteMap('assets/images/picoShoot');
		char.antialiasing = true;
		char.frames = FlxAnimateFrames.fromAnimate('$charPath/spritemap1.png', '$charPath/spritemap1.json');
		add(char);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.SPACE)
		{
			if (!char.isPlaying)
				char.playAnim();
			else
				char.pauseAnim();
		}

		char.x = FlxG.mouse.x;
		char.y = FlxG.mouse.y;

		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;

		super.update(elapsed);
	}
}
