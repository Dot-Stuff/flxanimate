package flxanimate;

import flixel.system.FlxAssets.FlxShader;

class Filters
{
	public var shader(default, null):FilterShader;
    public var hue(default, null):Float = 0;
	public var saturation(default, null):Float = 0;

	public function new():Void
	{
		shader = new FilterShader();
        hue = 0;
		saturation = 0;
        shader.hue.value = [hue];
		shader.saturation.value = [saturation];
	}

	public function setHue(hue:Float):Void
	{
		this.hue = hue;
		shader.hue.value[0] = hue;
	}
	public function setSaturation(saturation:Float):Void
	{
		this.saturation = saturation;
		shader.saturation.value[0] = saturation;
	}
}

class FilterShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform float hue;
		uniform float saturation;

		vec3 rgb2hsv(vec3 c)
		{
			vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
			vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

			float d = q.x - min(q.w, q.y);
			float e = 1.0e-10;
			return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		vec3 hsv2rgb(vec3 c)
		{
			vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
			vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
			return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
		}

		void main()
		{
			vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

			vec3 hsv = rgb2hsv(vec3(color[0], color[1], color[2]));
			// [0] == hue
			hsv[0] = hue;
			// [1] == saturation?
			hsv[1] += saturation;

			color = vec4(hsv2rgb(hsv), color[3]);
		
			
			gl_FragColor = color;
		}')
	public function new()
	{
		super();
	}
}