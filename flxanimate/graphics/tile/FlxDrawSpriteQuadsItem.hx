package flxanimate.graphics.tile;

import flixel.FlxCamera;
import openfl.display.Sprite;
import flixel.graphics.tile.FlxDrawQuadsItem;
class FlxDrawSpriteQuadsItem extends FlxDrawQuadsItem
{
    public var sprite:Sprite;
    public var _camera:FlxCamera;

    public function new()
    {
        super();
        sprite = null;
    }
    override public function reset() 
    {
        super.reset();
        _camera.canvas.removeChild(sprite);
        sprite = null;
    }
    override function dispose() 
    {
        super.dispose();
        _camera.canvas.removeChild(sprite);
        sprite = null;
        _camera = null;
    }
    override function render(camera:FlxCamera) 
    {
        if (_camera == null)
            _camera = camera;
        if (!_camera.canvas.contains(sprite))
            _camera.canvas.addChild(sprite);
    }
}