![](./logo.svg)

# FlxAnimate

A way to introduce texture atlases in your HaxeFlixel projects.

FlxAnimate introduces a way to add animations from texture atlases exported from Adobe Animate.
Texture atlases just pack symbols used in the animation, and have a `.json` file which describes how exactly it will be animated.

FlxAnimate is currently in development, so it's very possible that classes, functions and variables will be changed in the future.

# Usage
Using FlxAnimate is really simple! First, you have to create a new instance of FlxAnimate, just like you would with an FlxSprite.

```haxe
var character:FlxAnimate = new FlxAnimate(X, Y, PathToAtlas);
```

There is also a settings option when creating an FlxAnimate object, but that is optional and can be used if you wanted to set the framerate, antialiasing, what happens when the animation finishes, etc.

**CURRENTLY** you can only add animations with symbols and indices, we are planning to add animations by frame prefixes and symbols through layers.
Adding animations from a symbol:
```haxe
character.anim.addBySymbol(AnimationName, SymbolName, X, Y, Framerate);
```

Adding animations from indices:
```haxe
character.anim.addByAnimIndices(AnimationName, Indices ([0, 1, 2, 3...] etc.), Framerate);
```

**WARNING:** Adding animations by indices works only with the exported symbol and the main animation, don't try with different symbols as it will not work.

## TODO
* (optional/important) Masks and filters.

# Support
You don't have to do it, but if you feel like you want to support this repo, Please check my Discord `Miss Muffin#8930` And send an issue of what's it's giving you problems
