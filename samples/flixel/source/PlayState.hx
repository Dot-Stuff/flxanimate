package;

import flxanimate.FlxAnimate;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxG;

class PlayState extends FlxState
{
	var char:FlxAnimate;

	override public function create()
	{
		var bg = FlxGridOverlay.create(10, 10, FlxG.width * 4, FlxG.height * 4);
		bg.scrollFactor.set(0.5, 0.5);
		bg.screenCenter();
		add(bg);

		char = new FlxAnimate(0, 0, 'assets/images/ninja-girl');
		char.antialiasing = true;
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
