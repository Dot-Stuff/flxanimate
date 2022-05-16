package flxanimate;

import flixel.system.FlxAssets.FlxShader;

class Filters
{
	public var shader(default, null):#if !flash FilterShader #else Dynamic #end;

    public var hue(get, set):Float;
	public var saturation(get, set):Float;
	public var brightness(get, set):Float;

	public function new():Void
	{
		
		shader = new FilterShader();
		shader.HSV.value = [0, 1, 1];
        hue = 0;
		saturation = 0;
		brightness = 0;
	}

	function get_hue()
	{
		return shader.HSV.value[0] * 360;
	}
	function set_hue(hue:Float)
	{
		shader.HSV.value[0] = hue / 360;
		return hue;
	}
	function get_saturation()
	{
		return (shader.HSV.value[1] * 100) - 100;
	}
	function set_saturation(saturation:Float)
	{
		shader.HSV.value[1] = 1 + (saturation / 100);
		return saturation;
	}
	function get_brightness()
	{
		return (shader.HSV.value[2] * 100) - 100;
	}
	function set_brightness(brightness:Float)
	{
		shader.HSV.value[2] = 1 + (brightness / 100);
		return brightness;
	}
}

class FilterShader extends FlxShader
{
	@:glFragmentSource('
	#pragma header
	uniform vec3 HSV;
	
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
		
		// if accumulating the output, cyan, magenta, yellow, especially pastels
		// and of course whites are overexposed much sooner
		// than mostly-saturated red, green, or blue
		// a work around is by normalizing the last mix before applying the gain, like so:
		// return c.z * normalize(mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y));
	}

	void main(){
		vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
		vec3 fragRGB = textureColor.rgb;
		vec3 fragHSV = rgb2hsv(fragRGB).xyz;
		fragHSV.x += mod(HSV.x, 1.0);
		fragHSV.yz *= HSV.yz;

		fragRGB = hsv2rgb(fragHSV);
		gl_FragColor = vec4(fragRGB, textureColor.w);
	}
	')
	public function new()
	{
		super();
	}
}