package flxanimate;

import flixel.math.FlxMath;
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
		shader.HSV.value = [];
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
		shader.HSV.value[0] = (hue / 360) % 1;
		return hue;
	}
	function get_saturation()
	{
		return (shader.HSV.value[1] * 100) - 100;
	}
	function set_saturation(saturation:Float)
	{
		shader.HSV.value[1] = saturation / 100;
		return saturation;
	}
	function get_brightness()
	{
		return (shader.HSV.value[2] * 100) - 100;
	}
	function set_brightness(brightness:Float)
	{
		shader.HSV.value[2] = brightness / 100;
		return brightness;
	}
}

class FilterShader extends FlxShader
{
	@:glFragmentSource("
	#pragma header
	uniform vec3 HSV;

	vec3 hue2rgb(float hue){
		hue=fract(hue);
		return clamp(vec3(
			abs(hue*6.-3.)-1.,
			2.-abs(hue*6.-2.),
			2.-abs(hue*6.-4.)
		), 0., 1.);
	}
	vec3 rgb2hsl(vec3 c)
	{
		float cMin=min(min(c.r,c.g),c.b),
			  cMax=max(max(c.r,c.g),c.b),
			  delta=cMax-cMin;
		vec3 hsl=vec3(0.,0.,(cMax+cMin)/2.);
		if(delta!=0.0){ //If it has chroma and isn't gray.
			if(hsl.z<.5){
				hsl.y=delta/(cMax+cMin); //Saturation.
			}else{
				hsl.y=delta/(2.-cMax-cMin); //Saturation.
			}
			float deltaR=(((cMax-c.r)/6.)+(delta/2.))/delta,
				  deltaG=(((cMax-c.g)/6.)+(delta/2.))/delta,
				  deltaB=(((cMax-c.b)/6.)+(delta/2.))/delta;
			//Hue.
			if(c.r==cMax){
				hsl.x=deltaB-deltaG;
			}else if(c.g==cMax){
				hsl.x=(1./3.)+deltaR-deltaB;
			}else{ //if(c.b==cMax){
				hsl.x=(2./3.)+deltaG-deltaR;
			}
			hsl.x=fract(hsl.x);
		}
		return hsl;
	}
	
	vec3 hsl2rgb(vec3 hsl){
		if(hsl.y==0.){
			return vec3(hsl.z); //Luminance.
		}else{
			float b;
			if(hsl.z<.5){
				b=hsl.z*(1.+hsl.y);
			}else{
				b=hsl.z+hsl.y-hsl.y*hsl.z;
			}
			float a=2.*hsl.z-b;
			return a+hue2rgb(hsl.x)*(b-a);
			/*vec3(
				hueRamp(a,b,hsl.x+(1./3.)),
				hueRamp(a,b,hsl.x),
				hueRamp(a,b,hsl.x-(1./3.))
			);*/
		}
	}

	void main(){
		vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
		vec3 fragRGB = textureColor.rgb;
		vec3 fragHSV = rgb2hsl(fragRGB).xyz;
		fragHSV.x += mod(HSV.x, 1.0);
		fragHSV.yz += HSV.yz;

		fragRGB = hsl2rgb(fragHSV);
		gl_FragColor = vec4(fragRGB, textureColor.w);
	}
	")
	public function new()
	{
		super();
	}
}