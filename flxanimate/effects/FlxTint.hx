package flxanimate.effects;

import flixel.util.FlxColor;

/**
 * `FlxTint` lets you apply a color onto an object on a certain amount.
 */
class FlxTint extends FlxColorEffect 
{
    /**
     * a 0x​_RRGGBB_ `FlxColor` value.
     * **WARNING:** the `alpha` variable will be 
     * ignored, use multiplier instead!
     */
    public var tint(default, set):FlxColor;

    /**
     * The amount of color that should be applied
     * to the effect.
     * Works as relative `alpha` for the effect.
     */
    public var multiplier(default, set):Float;

    /**
     * Creates a new `FlxTint` instance.
     * @param tint A `FlxColor` value with the hexadecimal _RR_, _GG_, _BB_.
     * @param multiplier a decimal number representing the amount of tint applied.
     */
    public function new(tint:FlxColor, multiplier:Float)
    {
        super();
        this.tint = tint;
        this.multiplier = multiplier;
    }
    override public function process() 
    {
        c_Transform.redMultiplier -= multiplier;
        c_Transform.redOffset = Math.round(tint.red * multiplier);
        c_Transform.greenMultiplier -= multiplier;
        c_Transform.greenOffset = Math.round(tint.green * multiplier);
        c_Transform.blueMultiplier -= multiplier;
        c_Transform.blueOffset = Math.round(tint.blue * multiplier);
    }    

    function set_tint(value:FlxColor)
    {
        if (tint != value) renderDirty = true;

        return tint = value;
    }
    function set_multiplier(value:Float)
    {
        if (multiplier != value) renderDirty = true;

        return multiplier = value;
    }
}