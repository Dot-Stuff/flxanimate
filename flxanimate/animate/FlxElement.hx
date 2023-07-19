package flxanimate.animate;

import flxanimate.display.FlxAnimateFilterRenderer;
import openfl.display.BitmapData;
import openfl.Vector;
import flxanimate.geom.FlxMatrix3D;
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
     * The name of the bitmap itself.
     */
    public var bitmap(default, set):String;
    /**
     * The matrix that the symbol or bitmap has.
     */
    public var matrix(default, set):FlxMatrix;
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
        if (symbol != null)
            symbol._parent = this;
        this.matrix = (matrix == null) ? new FlxMatrix() : matrix;
    }

    public function toString()
    {
        return '{matrix: $matrix, bitmap: $bitmap}';
    }
    public function destroy()
    {
        _parent = null;
        if (symbol != null)
            symbol.destroy();
        bitmap = null;
        matrix = null;
    }

    function set_bitmap(value:String)
    {
        if (value != bitmap && symbol != null && symbol.cacheAsBitmap)
            symbol._renderDirty = true;

        return bitmap = value;
    }
    function set_matrix(value:FlxMatrix)
    {
        (value == null) ? matrix.identity() : matrix = value;

        return value;
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
            params.filters = AnimationData.fromFilterJson(element.SI.F);
        }
        
        var m3d = (symbol) ? element.SI.M3D : element.ASI.M3D;
        var array = Reflect.fields(m3d);
        if (!Std.isOfType(m3d, Array))
            array.sort((a, b) -> Std.parseInt(a.substring(1)) - Std.parseInt(b.substring(1)));
        var m:Array<Float> = (m3d is Array) ? m3d : [for (field in array) Reflect.field(m3d,field)];

        if (!symbol && m3d == null)
        {
            m[0] = m[5] = 1;
            m[1] = m[4] = m[12] = m[13] = 0;
        }

        var pos = (symbol) ? element.SI.bitmap.POS : element.ASI.POS;
        if (pos == null)
            pos = {x: 0, y: 0};
        return new FlxElement((symbol) ? element.SI.bitmap.N : element.ASI.N, params, new FlxMatrix(m[0], m[1], m[4], m[5], m[12], m[13]));
    }
}