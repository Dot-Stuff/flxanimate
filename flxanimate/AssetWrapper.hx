package flxanimate;

import haxe.io.Bytes;
import openfl.display.BitmapData;

import openfl.utils.Assets as OpenFLAssets;
import openfl.utils.AssetType as OpenFLAssetType;

import flixel.FlxG;
import flixel.system.frontEnds.AssetFrontEnd;

// wrapper for assets to allow flixel 6+ and flixel 5- compat
class AssetWrapper {
    public static function exists(path:String):Bool {
        #if (flixel >= "6.0.0")
        return FlxG.assets.exists(path);
        #else
        return OpenFLAssets.exists(path);
        #end
    }

    public static function getText(path:String):String {
        #if (flixel >= "6.0.0")
        return FlxG.assets.getText(path);
        #else
        return OpenFLAssets.getText(path);
        #end
    }

    public static function getBytes(path:String):Bytes {
        #if (flixel >= "6.0.0")
        return FlxG.assets.getBytes(path);
        #else
        return OpenFLAssets.getBytes(path);
        #end
    }

    public static function getBitmapData(path:String):BitmapData {
        #if (flixel >= "6.0.0")
        return FlxG.assets.getBitmapData(path);
        #else
        return OpenFLAssets.getBitmapData(path);
        #end
    }

    public static function list(?type:AssetType):Array<String> {
        #if (flixel >= "6.0.0")
        return FlxG.assets.list(type);
        #else
        return OpenFLAssets.list(type);
        #end
    }
}

typedef AssetType = #if (flixel >= "6.0.0") FlxAssetType #else OpenFLAssetType #end;