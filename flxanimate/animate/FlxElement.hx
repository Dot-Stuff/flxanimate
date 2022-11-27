package flxanimate.animate;

import flixel.math.FlxPoint;
import flxanimate.data.AnimationData;
import flixel.math.FlxMatrix;
import openfl.geom.ColorTransform;

class FlxElement 
{
    @:allow(flxanimate.animate.FlxKeyFrame)
    var _parent:FlxKeyFrame;
    /**
     * All the other parameters that are exclusive to the symbol (instance, type, symbol name, etc.)
     */
    public var symbol(default, null):SymbolParameters;
    /**
     * The name of the frame itself.
     */
    public var bitmap(default,null):String;
    /**
     * The matrix that the symbol or bitmap has.
     */
    public var matrix(default, null):FlxMatrix;
    /**
     * Creates a new `FlxElement` instance.
     * @param name the name of the element. `WARNING:` this name is dynamic, in other words, this name can used for the limb or the symbol!
     * @param symbol the symbol settings, ignore this if you want to add a limb.
     * @param matrix the matrix of the element.
     */
    public function new(?bitmap:String, ?symbol:SymbolParameters, ?matrix:FlxMatrix)
    {
        this.bitmap = bitmap;
        this.symbol = symbol;
        this.matrix = (matrix == null) ? new FlxMatrix() : matrix;
    }

    public function toString()
    {
        return '{matrix: $matrix, bitmap: $bitmap}';
    }
    public static function fromJSON(element:Element)
    {
        var symbol = element.SI != null;
        var params:SymbolParameters = null;
        if (symbol)
        {      
            params = new SymbolParameters();
            params.instance = element.SI.IN;
            params.type = switch (element.SI.ST)
            {
                case movieclip, "movieclip": MovieClip;
                case button, "button": Button;
                default: Graphic;
            }
            var lp:LoopType = (element.SI.LP == null) ? loop : element.SI.LP.split("R")[0];
            params.loop = switch (lp) // remove the reverse sufix
            {
                case playonce, "playonce": PlayOnce;
                case singleframe, "singleframe": SingleFrame;
                default: Loop;
            }
            params.reverse = (element.SI.LP == null) ? false : StringTools.contains(element.SI.LP, "R");
            params.firstFrame = element.SI.FF;
            params.colorEffect = AnimationData.fromColorJson(element.SI.C);
            params.name = element.SI.SN;
            params.transformationPoint = FlxPoint.weak(element.SI.TRP.x, element.SI.TRP.y);
        }
        
        var m3d = (symbol) ? element.SI.M3D : element.ASI.M3D;
        var m:Array<Float> = (m3d is Array) ? m3d : [for (field in Reflect.fields(m3d)) Reflect.field(m3d,field)];
        var pos = (symbol) ? element.SI.bitmap.POS : element.ASI.POS;
        if (pos == null)
            pos = {x: 0, y: 0};
        return new FlxElement((symbol) ? element.SI.bitmap.N : element.ASI.N, params, new FlxMatrix(m[0], m[1], m[4], m[5], m[12] + pos.x, m[13] + pos.y));
    }
}