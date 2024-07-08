package flxanimate.filters;

import flixel.system.FlxAssets.FlxShader;


/**
 * I did not steal this code from somewhere, specially not IADenner.
 */
class MaskShader extends FlxShader
{
	@:glFragmentSource('
	#pragma header

	uniform sampler2D mainPalette;

	uniform vec2 relativePos;

	void main()
	{
		vec2 maskPos = vec2(openfl_TextureCoordv.x + (relativePos.x), openfl_TextureCoordv.y + (relativePos.y));

		float maskAlpha = texture2D(mainPalette, maskPos).a;

		if ((maskPos.x < 0. || maskPos.x > 1.) || (maskPos.y < 0. || maskPos.y > 1.))
			maskAlpha = 0.;

		gl_FragColor = texture2D(bitmap, openfl_TextureCoordv) * maskAlpha;
	}
')

	public function new()
	{
		super();
		relativePos.value = [0, 0];
	}
}