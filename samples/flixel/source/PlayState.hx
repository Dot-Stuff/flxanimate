package;

import flxanimate.animate.FlxSpriteMap;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxG;

class PlayState extends FlxState
{
	var char:FlxSpriteMap;

	override public function create()
	{
		super.create();

		var bg = FlxGridOverlay.create(10, 10, FlxG.width * 4, FlxG.height * 4);
		bg.scrollFactor.set(0.5, 0.5);
		bg.screenCenter();
		add(bg);

		char = new FlxSpriteMap(0, 0, 'assets/images/picoShoot');
		add(char);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

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
	}
}
