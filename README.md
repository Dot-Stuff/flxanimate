![](./logo.svg)

# FlxAnimate

A way to introduce texture atlases in your HaxeFlixel projects.

FlxAnimate introduces a way to add animations from texture atlases exported from Adobe Animate.

A texture atlas is a method of exporting animations in Adobe Animate which exports a specific symbol. In every texture atlas there will be atleast 3 files (depending on the version you're using):
- `Animation.json` - Determines the main timeline plus the timelines of symbols within the animation.
- `spritemap(1).json` - Determines the sprites and assets needed for the animation.
- `spritemap(1).png` - An image containing the assets needed for the animation.

FlxAnimate is currently in development, so it's very possible that classes, functions and variables will be changed in the future.

## Installation
Installing FlxAnimate is as simple as running:
```
haxelib install flxanimate
```
in your terminal or command prompt!

## Usage
Using FlxAnimate is really simple! First, you have to create a new instance of FlxAnimate, just like you would with an FlxSprite.

```haxe
var character:FlxAnimate = new FlxAnimate(X, Y, PathToAtlas);
```

There is also a settings option when creating an FlxAnimate object used just in case if you wanted to initialise the variables in a JSON, and it's up to you if you wanted to use it.

**CURRENTLY** you can add animations from frame labels, symbols and indices. Support for stamping symbols is planned for later updates.
Adding animations from a symbol:
```haxe
character.anim.addBySymbol(AnimationName, SymbolName, X, Y, Framerate);
```

Adding animations from indices:
```haxe
character.anim.addByAnimIndices(AnimationName, Indices ([0, 1, 2, 3...] etc.), Framerate);
```

**WARNING:** Adding animations by indices works only with the exported timeline and the main animation, don't try with different symbols as it will not work.

## TODO
* (optional/important) Masks and filters.

## Support
You don't have to do it, but if you feel like you want to support this repo, Please check my Discord `Miss Muffin#8930` And send an issue of what's it's giving you problems
