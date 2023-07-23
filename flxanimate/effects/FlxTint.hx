package flxanimate.effects;

import flixel.util.FlxColor;

using flixel.util.FlxColorTransformUtil;
/**
 * `FlxTint` lets you apply a color onto an object on a certain amount.
 */
class FlxTint extends FlxColorEffect 
{
    /**
     * a 0x​_AARRGGBB_ `FlxColor` value.
     * The strength of the tint is used by the color's alpha.
     */
    public var tint(default, set):FlxColor;

    /**
     * Creates a new `FlxTint` instance.
     * @param tint A `FlxColor` value with the hexadecimal _RR_, _GG_, _BB_.
     * @param multiplier a decimal number representing the amount of tint applied.
     */
    public function new(tint:FlxColor, multiplier:Float)
    {
        super();
        tint.alphaFloat = multiplier;
        this.tint = tint;
    }
    override public function process() 
    {
        var multiplier = tint.alphaFloat;
        var cMultiplier = 1 - multiplier;
        c_Transform.redMultiplier = cMultiplier;
        c_Transform.redOffset = Math.round(tint.red * multiplier);
        c_Transform.greenMultiplier = cMultiplier;
        c_Transform.greenOffset = Math.round(tint.green * multiplier);
        c_Transform.blueMultiplier = cMultiplier;
        c_Transform.blueOffset = Math.round(tint.blue * multiplier);
    }    

    function set_tint(value:FlxColor)
    {
        if (tint != value) renderDirty = true;

        return tint = value;
    }
}