package flxanimate.animate;

import haxe.extern.EitherType;
import flixel.math.FlxMatrix;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.FlxGraphic;
import openfl.filters.BitmapFilter;
import flixel.math.FlxPoint;
import openfl.geom.ColorTransform;
import flxanimate.data.AnimationData;
import flxanimate.effects.FlxColorEffect;
/**
 * `SymbolParameters` defines and separates from what a `FlxElement` considered as a `Shape` and a `FlxElement` considered as a `Symbol`.
 * 
 * It adds metadata information on the symbol's behaviour, such as:
 * - `Type`, this can be considered as:
 *      - Type of `Symbol`.
 *      - Type of `Looping`.
 * - `Effects`, such as:
 *      - `Color Effects`.
 *      - `Filters`.
 * - Symbol `Animation` behaviour.
 * 
 * We do not recommend extending this class unless you know what you're doing!
 */
class SymbolParameters
{
    @:allow(flxanimate.animate.FlxElement)
    var _parent:FlxElement;
    @:allow(flxanimate.FlxAnimate)
    var _filterBitmap:FlxFrame;

    /**
     * The `FlxElement`'s own name identifier. **WARNING:** do NOT confuse with `name`!
     */
    public var instance:String;
    
    /**
     * The type of the symbol, this may vary in three categories:
     * - Graphic
     * - MovieClip
     * - Button.
     * @see [Types of Symbols](https://helpx.adobe.com/animate/how-to/types-of-symbols.html)
     */
    public var type(default, set):SymbolT;
    /**
     * The type of loop that the symbol is been set to.
     * There are three types (excluding the reversed options):
     * - Loop
     * - Play Once
     * - Single Frame.
     * **WARNING:** if `type` is **NOT** set to `Graphic`, this option will not let you modify it. 
     */
    public var loop(default, set):Loop;
    /**
     * Whether the looping animation is reversed or not.
     * It is ignored when `loop` is set to `SingleFrame`.
     */
    public var reverse:Bool;
    /**
     * An `Int` that references the frame of the referenced symbol.
     */
    public var firstFrame(default, set):Int;

    @:allow(flxanimate.FlxAnimate)
    /**
     * Internal, checks the current frame it's at at the moment to force a filter render.
     */
    var _curFrame:Int;
    /**
     * The referenced symbol's name. **WARNING:** do NOT confuse with `instance`!
     */
    public var name:String;

    public var colorEffect(default, set):FlxColorEffect;

    public var cacheAsBitmap(get, set):Bool;

    var _cacheAsBitmap:Bool = false;

    @:allow(flxanimate.animate.FlxElement)
    @:allow(flxanimate.FlxAnimate)
    @:allow(flxanimate.animate.FlxKeyFrame)
    var _renderDirty:Bool = false;

    @:allow(flxanimate.animate.FlxKeyFrame)
    @:allow(flxanimate.FlxAnimate)
    var _layerDirty:Bool = false;

    @:allow(flxanimate.FlxAnimate)
    @:allow(flxanimate.animate.FlxAnim)
    var _colorEffect(get, null):ColorTransform;
    
    public var transformationPoint:FlxPoint;

    public var filters(default, set):Array<BitmapFilter>;

    public var cacheAsBitmapMatrix:FlxMatrix;

    @:allow(flxanimate.FlxAnimate)
    var _cacheBitmapMatrix:FlxMatrix;
    
    
    /**
     * Creates a new `SymbolParameters` instance.
     * @param name The name referencing an existing symbol.
     * @param instance The name of this instance.
     * @param type The Type of Symbol it will behave like.
     * @param loop The type of looping it will use. **WARNING:** This can be ignored if `type` isn't set to `Graphic`!
     * 
     */
    public function new(?name:String = null, ?instance:String = "", ?type:SymbolT = Graphic, ?loop:Loop = Loop)
    {
        this.name = name;
        this.instance = instance;
        this.type = type;
        this.loop = loop;
        firstFrame = 0;
        transformationPoint = new FlxPoint();
        colorEffect = None;
        _curFrame = -1;
        filters = null;
        cacheAsBitmapMatrix = new FlxMatrix();
        _cacheBitmapMatrix = new FlxMatrix();
    }

    public function destroy()
    {
        instance = null;
        type = null;
        reverse = false;
        firstFrame = 0;
        name = null;
        colorEffect = null;
        transformationPoint = null;
    }

    function set_type(type:SymbolT)
    {
        this.type = type;
        loop = (type == null) ? null : Loop;

        if (type == Graphic)
        {
            filters = null;
            FlxDestroyUtil.destroy(_filterBitmap);
            cacheAsBitmap = false;
        }

        return type;
    }

    @:allow(flxanimate.animate.FlxKeyFrame)
    @:allow(flxanimate.FlxAnimate)
    function update()
    {
        if (filters == null || filters.length == 0 || _renderDirty) return;

        for (filter in filters)
        {
            @:privateAccess
            if (filter.__renderDirty)
            {
                _renderDirty = true;
                return;
            }
        }
    }

    function set_loop(loop:Loop)
    {
        if (type == null) return this.loop = null;
        this.loop = switch (type)
        {
            case MovieClip: Loop;
            case Button: SingleFrame;
            default: loop;
        }

        return loop;
    }

    function set_firstFrame(value:Int)
    {
        if (type == Graphic && firstFrame != value) 
        {
            firstFrame = value;
            _layerDirty = true;
        }

        return value;
    }

    public function reset()
    {
        name = null;
        type = Graphic;
        loop = Loop;
        instance = "";
        firstFrame = 0;
        transformationPoint.set();
        colorEffect = None;
    }

    function get__colorEffect()
    {
        return null;
    }

    function set_colorEffect(value:EitherType<ColorEffect, FlxColorEffect>)
    {
        if (cacheAsBitmap)
            _renderDirty = true;

        if (value == null)
            value = None;
        
        if ((value is ColorEffect))
        {
            colorEffect = AnimationData.parseColorEffect(value);
        }
        else
            colorEffect = value;
        
        return colorEffect;
    }

    function set_filters(filters:Array<BitmapFilter>)
    {
        if (type == Graphic) return null;

        if (filters != null && filters.length > 0)
        {
            _renderDirty = true;
        }

        else
        {
            if (_cacheAsBitmap)
                _renderDirty = true;
            else
                _filterBitmap = FlxDestroyUtil.destroy(_filterBitmap);
                
        }

        return this.filters = filters;
    }

    function get_cacheAsBitmap()
    {
        if (type == Graphic) return false;


        if (filters != null && filters.length > 0) return true;

        return _cacheAsBitmap;
    }
    function set_cacheAsBitmap(value:Bool)
    {
        if (type == Graphic) return false;

        if (value) _renderDirty = true;

        return _cacheAsBitmap = value;
    }
}