package;

import flixel.FlxGame;
import flixel.util.FlxColor;
import openfl.display.Sprite;
import openfl.display.FPS;

class Main extends Sprite
{
	var framerate:Int = #if web 60 #else 144 #end;

	public function new()
	{
		super();

		addChild(new FlxGame(1280, 720, PlayState, #if (flixel < "5.0.0") 1,#end framerate, framerate, true, false));

		var fpsCounter = new FPS(10, 3, FlxColor.BLACK);
		addChild(fpsCounter);
	}
}
