package flxanimate.animate;

import flixel.FlxG;
import flxanimate.data.AnimationData;
import openfl.geom.ColorTransform;
import flixel.math.FlxMatrix;

class FlxSymbol
{
    public var timeline(default, null):Timeline;

    public var length(default, null):Int;

    public var name(default, null):String;

    public var labels(default, null):Map<String, FlxLabel>;

    var _labels:Array<String>;
    
    public var layers(default, null):Array<String>;
    
    var _layers:Array<String>;
    
    public var curFrame:Int;

    @:allow(flxanimate.animate.FlxAnim)
    function new(name:String, timeline:Timeline, reverse:Bool = false)
    {
        layers = [];
        labels = [];
        _labels = [];
        curFrame = 0;
        if (reverse)
            timeline.L.reverse();
        for (layer in timeline.L)
		{
            layer = parseLayer(layer);
        }
        _layers = layers;
        length--;
        this.timeline = timeline;
    }

    function parseLayer(layer:Layers)
    {
        layers.push(layer.LN);
        for (fr in layer.FR)
        {
            if (fr.N != null)
            {
                labels.set(fr.N, new FlxLabel(fr.N, fr.I));
                _labels.push(fr.N);
            }
            for (element in fr.E)
            {
                var ASI = element.ASI;
                var SI = element.SI;
                if (ASI != null)
                {
                    ASI.M3D = (ASI.M3D != null) ? (ASI.M3D is Array) ? ASI.M3D : [ASI.M3D.m00,ASI.M3D.m01,ASI.M3D.m02,ASI.M3D.m03,ASI.M3D.m10,ASI.M3D.m11,ASI.M3D.m12,ASI.M3D.m13,
                        ASI.M3D.m20,ASI.M3D.m21,ASI.M3D.m22,ASI.M3D.m23,ASI.M3D.m30,ASI.M3D.m31,ASI.M3D.m32,ASI.M3D.m33] : [1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1];

                    if (ASI.POS != null)
                    {
                        ASI.M3D[12] += ASI.POS.x;
                        ASI.M3D[13] += ASI.POS.y;
                    }
                }
                if (SI != null)
                {
                    SI.M3D = (SI.M3D is Array) ? SI.M3D : [SI.M3D.m00, SI.M3D.m01,SI.M3D.m02,SI.M3D.m03,SI.M3D.m10,SI.M3D.m11,SI.M3D.m12,SI.M3D.m13,SI.M3D.m20,SI.M3D.m21,SI.M3D.m22,
                        SI.M3D.m23,SI.M3D.m30,SI.M3D.m31,SI.M3D.m32,SI.M3D.m33];

                    if (SI.bitmap != null)
                    {
                        SI.M3D[12] += SI.bitmap.POS.x;
                        SI.M3D[13] += SI.bitmap.POS.y;
                    }
                }
            }
            layer.FR = AnimationData.parseDurationFrames(layer.FR);
            if (length < fr.I + fr.DU)
                length = fr.I + fr.DU;
        }
        return layer;
    }
    public function hideLayer(layer:String)
    {
        if (!layers.contains(layer))
            FlxG.log.error('There is no layer called "$layer"!');
        layers.remove(layer);
    }
    public function showLayer(layer:String)
    {
        if (!_layers.contains(layer))
        {
            FlxG.log.error('There is no layer called "$layer"!');
            return;
        }
        layers.push(layer);
    }
    public function addCallbackTo(label:String, callback:()->Void)
    {
        if (!labels.exists(label))
        {
            FlxG.log.error('there is not label called "$label"!');
            return;
        }
        var label = labels.get(label);
        
        if (label.callbacks.indexOf(callback) != -1)
        {
            FlxG.log.error("this callback already exists!");
            return;
        }
        label.callbacks.push(callback);
    }
    public function removeCallbackFrom(label:String, callback:()->Void)
    {
        if (!labels.exists(label))
        {
            FlxG.log.error('there is not label called "$label"!');
            return;
        }
        var label = labels.get(label);
        
        if (label.callbacks.indexOf(callback) == -1)
        {
            FlxG.log.error("this callback doesn't exist!");
        }
        label.callbacks.remove(callback);
    }
    public function removeAllCallbacksFrom(label:String)
    {
        if (!labels.exists(label))
        {
            FlxG.log.error('there is not label called "$label"!');
            return;
        }
        labels.get(label).removeCallbacks();
    }
    public function getNextToFrameLabel(label:String):FlxLabel
    {
        var good:Bool = false;
        for (_label in _labels)
        {
            if (good)
                return labels.get(_label);
            if (_label == label)
                good = true;
        }
        
        FlxG.log.error('"$label" doesnt exist! Maybe you misspelled it?');
        return null;
    }
    public function frameControl(frame:Int, loopType:LoopType)
    {
        if (frame < 0)
		{
			if ([loop, "loop"].indexOf(loopType) != -1)
				frame += (length > 0) ? length: frame;
			else
			{
				frame = 0;
			}
			
		}
		else if (frame > length)
		{
			if ([loop, "loop"].indexOf(loopType) != -1)
			{
				frame -= (length > 0) ? length : frame;
			}
			else
			{
				frame = length;
			}
		}

        return frame;
    }

    public function update(elapsed:Int, loopType:LoopType)
    {
        curFrame = frameControl(curFrame + elapsed, loopType);
    }
    public function prepareMatrix(m3d:Array<Float>)
	{
		if (m3d == null || m3d == [])
			m3d = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]; // default m3d?

		return new FlxMatrix(m3d[0], m3d[1], m3d[4], m3d[5], m3d[12], m3d[13]);
	}
}
