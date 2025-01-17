package flxanimate.interfaces;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.FlxCamera;

interface IFilterable
{
	@:allow(flxanimate.FlxAnimate)
	private var _filterCamera:FlxCamera;
	@:allow(flxanimate.FlxAnimate)
	@:allow(flxanimate.filters.FlxAnimateFilterRenderer)
	private var _filterFrame:FlxFrame;
	@:allow(flxanimate.FlxAnimate)
	@:allow(flxanimate.filters.FlxAnimateFilterRenderer)
	private var _bmp1:BitmapData;
	@:allow(flxanimate.FlxAnimate)
	@:allow(flxanimate.filters.FlxAnimateFilterRenderer)
	private var _bmp2:BitmapData;
	@:allow(flxanimate.FlxAnimate)
	private var _filterMatrix:FlxMatrix;

	@:allow(flxanimate.FlxAnimate)
	private function updateBitmaps(rect:Rectangle):Void;
}