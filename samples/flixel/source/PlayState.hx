package;

import openfl.display.Bitmap;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.OpenGLRenderer;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flxanimate.FlxAnimate;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxG;

class PlayState extends FlxState
{
	// variables you can change to see how it can vary the sample.
	/**
	 * a `Bool` check to see how it differs from optimised to unoptimised.**WARNING:** if the texture atlas doesn't provide a optimised/unoptimised counterpart, it may crash! 
	 */
	var optimised:Bool = true;
	/**
	 * Checks if the memory used should be only used for the texture atlas only.
	 */
	var optimiseMemory:Bool = false;
	
	// Controls.
	
	/**
	 * Crouch controls.
	 */
	var crouch:Array<FlxKey> = [SHIFT, C];
	/**
	 * Attack controls.
	 */
	var attack:Array<FlxKey> = [SPACE, ENTER];
	/**
	 * Walk controls.
	 */
	var walk:Array<Array<FlxKey>> = [[LEFT, A], [RIGHT, D], [UP, W],  [DOWN, S]];

	var velocity = 150;
	
	// variables that it is not recommended to change, work with precaution.
	var textCamera:FlxCamera;
	var char:FlxAnimate;
	var grpLabels:FlxTypedSpriteGroup<FlxText>;
	var labels:Array<String>;
	var specialAnim:Bool = false;
	var sprite:FlxSprite;

	override public function create()
	{
		@:privateAccess
		cast(FlxG.scaleMode, flixel.system.scaleModes.RatioScaleMode).fillScreen = true;

		if (!optimiseMemory)
		{
			var bg = FlxGridOverlay.create(10, 10);
			add(bg);
		}
		char = new FlxAnimate(0, 0, 'assets/images/ninja-girl');
		char.screenCenter();
		char.antialiasing = true;
		add(char);
		var bitmapData:BitmapData = null;

		@:privateAccess
		if (true)
		{
			bitmapData = new BitmapData(250, 250, 0);

			bitmapData.fillRect(new openfl.geom.Rectangle(125, 125, 100, 100), 0xFF0000FF);

			trace(char._sprite.graphics.__bitmap);

			// var renderer:OpenGLRenderer = cast FlxG.stage.__renderer;
			// var filter = new openfl.filters.BlurFilter(25, 0);

			// var shader = new FlxShader();
			// var context3D = FlxG.stage.context3D;
			// var bmp = new Bitmap(bitmapData);
			// bmp.filters = new openfl.filters.BlurFilter();
		}
		@:privateAccess
		sprite = new FlxSprite();
		sprite.screenCenter();
		add(sprite);

		labels = char.anim.getFrameLabels();
		if (!optimiseMemory)
		{
			textCamera = new FlxCamera();
			textCamera.bgColor = 0;
			FlxG.cameras.add(textCamera, false);

			grpLabels = new FlxTypedSpriteGroup();
			var curLabelTxt = new FlxText("CURRENT LABEL: ", 32);
			grpLabels.add(curLabelTxt);
			grpLabels.add(new FlxText(curLabelTxt.x + curLabelTxt.width + 20, curLabelTxt.y, "", 32));
			grpLabels.camera = textCamera;

			grpLabels.members[0].color = FlxColor.RED;

			add(grpLabels);
		}
		setAnimationLabel(0);

		super.create();
	}

	var keys:Array<FlxKey> = null;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		@:privateAccess
		// if (FlxG.keys.justPressed.R)
		// 	sprite.loadGraphic(char._sprite.__cacheBitmap.bitmapData);

		var keyJustPressed:FlxKey = FlxG.keys.firstJustPressed();		
		
		if (crouch.indexOf(keyJustPressed) != -1 || attack.indexOf(keyJustPressed) != -1)
		{
			specialAnim = true;

			setAnimationLabel((crouch.indexOf(keyJustPressed) != -1) ? 2 : 3, true, () -> specialAnim = false);
		}

		if (specialAnim) return;


		var keyPressed:FlxKey = FlxG.keys.firstPressed();
		
		if (keyPressed != NONE)
		{
			for (arr in walk)
			{
				if (arr.indexOf(keyPressed) != -1)
				{
					keys = arr;
					break;
				}
			}
			
			var i = walk.indexOf(keys);

			if ([0, 1].indexOf(i) != -1)
			{
				char.flipX = i == 0;

				char.x += ((!char.flipX) ? velocity : -velocity) * elapsed;
			}
			else
				char.y += ((i == 3) ? velocity : -velocity) * elapsed;

			setAnimationLabel(1);
		}
		else
			setAnimationLabel(0);
	}

	function setAnimationLabel(label:Int, reset:Bool = false, onComplete:()->Void = null)
	{
		var txt = grpLabels.members[1];
		if (txt.text == labels[label] && !reset)
			return;
		
		if (txt.text != "")
		{
			char.anim.removeAllCallbacksFrom(txt.text);
			char.anim.removeAllCallbacksFrom(labels[(labels.indexOf(txt.text) + 1) % labels.length]);
		}

		char.anim.getFrameLabel(labels[(label + 1) % labels.length]).add(()-> 
		{
			if (onComplete != null)
				onComplete();
			char.anim.goToFrameLabel(labels[label]);
		});
		if (!optimiseMemory)
		{
			grpLabels.members[1].text = labels[label];
			grpLabels.screenCenter(X);
		}
		char.anim.goToFrameLabel(labels[label]);
	}
}