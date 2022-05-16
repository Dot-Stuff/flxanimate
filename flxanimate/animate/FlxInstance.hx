package flxanimate.animate;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxMath;
import flxanimate.data.AnimationData;
import flixel.math.FlxMatrix;

class FlxInstance extends FlxAnim
{
    public var isSymbol:Bool = false;
	public var limb:Null<String> = null;
	
	public function new(SymbolReference:FlxAnim, ?SI:SymbolInstance) 
	{
		super(SymbolReference.x, SymbolReference.y, null);
		
		antialiasing = SymbolReference.antialiasing;
		offset = SymbolReference.offset;
		xFlip = SymbolReference.xFlip;
		yFlip = SymbolReference.yFlip;
		scrollFactor = SymbolReference.scrollFactor;
		cameras = SymbolReference.cameras;
		camera = SymbolReference.camera;
        colorTransform.concat(SymbolReference.colorTransform);
        frames = SymbolReference.frames;
		
        if (SI == null) return;

		isSymbol = true;
		symbolDictionary = SymbolReference.symbolDictionary;
		timeline = symbolDictionary.get(SI.SN);

		if (SI.bitmap == null)
			frameLength = setSymbolLength(timeline);
		symbolType = SI.ST;
		symbolName = SI.SN;
		if (["G", "graphic"].indexOf(symbolType) != -1)
		{
			curFrame = SI.FF; 
			loopType = SI.LP;
		}
		else
			loopType = singleframe;

		if (SI.C != null)
		{
			addColorEffect(SI.C);
		}
	}

	override function isOnScreen(?Camera:FlxCamera):Bool 
	{
		if (Camera == null)
			Camera = FlxG.camera;


		var minX:Float = x + _matrix.tx - offset.x - scrollFactor.x * Camera.scroll.x;
		var minY:Float = y + _matrix.ty - offset.y - scrollFactor.y * Camera.scroll.y;

		var radiusX:Float =  frameHeight * Math.max(1,_matrix.a);
		var radiusY:Float = frameWidth * Math.max(1, _matrix.d);
		var radius:Float = Math.max(radiusX, radiusY);
		radius *= FlxMath.SQUARE_ROOT_OF_TWO;
		minY -= radius;
		minX -= radius;
		radius *= 2;

		_point.set(minX, minY);
		return Camera.containsPoint(_point, radius, radius);
	}

	override public function render()
	{
		if (timeline != null)
			super.render();
		else
		{
			frame = frames.getByName(limb);
        	draw();
		}
	}
	
	public static function prepareMatrix(m3d:Array<Float>)
	{
		return new FlxMatrix(m3d[0], m3d[1], m3d[4], m3d[5], m3d[12], m3d[13]);
	}

	override function drawComplex(camera:FlxCamera):Void
	{
		_matrix.scale(scale.x, scale.y);
		if (bakedRotationAngle <= 0)
		{
			updateTrig();
			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}
		if (isPixelPerfectRender(camera))
		{
			_point.floor();
		}

		_matrix.translate(_point.x, _point.y);
		// testing shaders? not having much success as I want to smh
		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, AnimationData.filters.shader);
	}
}