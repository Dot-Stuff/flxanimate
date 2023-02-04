package;

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
	 
	// variables that it is not recommended to change, work with precaution.
	var textCamera:FlxCamera;
	var char:FlxAnimate;
	var grpLabels:FlxTypedSpriteGroup<FlxText>;
	var labels:Array<String>;

	override public function create()
	{
		if (!optimiseMemory)
		{
			var bg = FlxGridOverlay.create(10, 10);
			add(bg);
		}
		char = new FlxAnimate(0, 0, 'assets/images/ninja-girl');
		char.screenCenter();
		char.antialiasing = true;
		add(char);

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

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.SPACE)
			(!char.anim.isPlaying) ? char.anim.play() : char.anim.pause();

		if (FlxG.keys.anyJustPressed([ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE]))
			setAnimationLabel(cast Math.min(FlxG.keys.firstJustPressed() - 49, labels.length - 1));
		
		if (FlxG.mouse.pressed)
			char.setPosition(FlxG.mouse.x, FlxG.mouse.y);

		super.update(elapsed);
	}

	function setAnimationLabel(label:Int)
	{
		for (label in labels)
		{
			char.anim.removeAllCallbacksFrom(label);
		}
		char.anim.getFrameLabel(labels[(label + 1) % labels.length]).add(()-> char.anim.goToFrameLabel(labels[label]));
		if (!optimiseMemory)
		{
			grpLabels.members[1].text = labels[label];
			grpLabels.screenCenter(X);
		}
		char.anim.goToFrameLabel(labels[label]);
	}
}