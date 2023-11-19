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
		if (FlxG.keys.justPressed.SPACE || FlxG.mouse.pressed)
		{
			if (!char.anim.isPlaying)
				char.anim.play();
			else
				char.anim.pause();
		}

		char.x = FlxG.mouse.x - 300;
		char.y = FlxG.mouse.y - 300;

		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;
		
		if (FlxG.mouse.wheel != 0)
			FlxG.camera.zoom += FlxG.mouse.wheel * #if html5 1 #else 0.02 #end;
		
		if (FlxG.camera.zoom < 0.5)
			FlxG.camera.zoom = 0.5;
		
		if (FlxG.camera.zoom > 2.0)
			FlxG.camera.zoom = 2.0;

		super.update(elapsed);
	}
}
