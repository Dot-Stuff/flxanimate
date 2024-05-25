package flxanimate.effects;

import openfl.geom.ColorTransform;

/**
 * `FlxColorEffect` is the base class for all color transformation effects.
 * The `FlxTint`, `FlxAlpha`, `FlxBrightness` and `FlxAdvanced` all extend
 * to `FlxColorEffect`. You can apply your own effects to the texture atlas
 * by extending this class.
 * Instancing this class will create a hollow effect that doesn't create any
 * visual difference.
 */
class FlxColorEffect
{
	@:allow(flxanimate.animate.SymbolParameters)
	/**
	 * Represents when to process the new values into `c_Transform`.
	 */
	var renderDirty:Bool = true;

	@:allow(flxanimate.FlxAnimate)
	/**
	 * Represents the colorTransform variable
	 */
	var c_Transform:ColorTransform = null;

	/**
	 * Creates an instance of `FlxColorEffect`.
	 */
	public function new()
	{
		c_Transform = new ColorTransform();

		process();
	}

	/**
	 * The function where the whole color effect makes it's processing.
	 */
	public function process() {}

	/**
	 * Internal, used to put the color Effect easily.
	 */
	@:allow(flxanimate.FlxAnimate)
	@:noCompletion function __create()
	{
		if (renderDirty) {
			process();
			renderDirty = false;
		}

		return c_Transform;
	}
}