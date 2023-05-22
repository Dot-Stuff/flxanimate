![](./logo.svg)

# FlxAnimate

FlxAnimate is a repository made by [CheemsAndFriends](https://github.com/CheemsAndFriends) and [DotWith](https://github.com/DotWith) made for playing all spritesheet formats and the mysterious but interesting export called `Texture Atlas`

## Support
You don't have to do it, but if you feel like you want to support this repo, Please check my Discord `CheemsNFriends#8930` And send an issue of what's it's giving you problems

## TODO
* Filters are a feature in early days of Flash that are commonly used to "spice up" the animation. Although the texture atlas does export these filters, they aren't supported. **IMPORTANT**
* Masks are clipping masks. not really important in our plans but still in our plans to support.
* Put a solution to the memory leakage 

# Installation

there are two ways of downloading FlxAnimate:

## 1. By haxelib:

Normally, haxelib tries (but sometimes fails) to be the most stable version of it.

You can download it by typing:
```
haxelib install flxanimate
```
in your terminal or command prompt.

## 2. By git:

if you want to use the latest commits that are released from time to time, type this command:
```
haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate
```
on your terminal or command prompt.


# Texture Atlas

**WARNING:** This repo's texture atlas player does not support **SPRITESHEET EXPORTS!!!** if you want to translate from atlases to spritesheets (even though I 100% don't recommend), use [Smokey's repo](https://github.com/Smokey555/Flixel-TextureAtlas)


A Texture Atlas is one of the methods of exporting animations in Adobe Animate which it can only export a single symbol. In every texture atlas, no matter if it is 2018 or the latest one, there will be atleast 2 main types:
- `Animation` - explains the timelines of the main animation plus the symbols that the main one uses.
- `spritemap` - slices the limbs that are used in the animation, it can variate from 1 to infinite really.

"FlxAnimate is literally so fuckin fragile I don't wanna call it a final version unless it has all the fuckin functions." - CheemsAndFriends

As you can see, even though this is trying to do it's best to work properly, it is very fragile, so it might break up sometimes in some versions, not to mention, it is kinda irregular and it will have breaking changes all the time. Hope you can understand and we apologize for the inconveniences.

## Usage
Using FlxAnimate is really simple! First, you have to create a new instance of FlxAnimate, just like you would with an FlxSprite.

```haxe
var character:FlxAnimate = new FlxAnimate(X, Y, PathToAtlas);
```
**WARNING:** You will need to set the Path of the folder, not the Animation file nor the Spritemap file, just the folder.

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


## SpriteSheet
It's basically the same thing you were doing when you were loading the frames, like Sparrow or JSON (Hash or Array).
But this time it adds even more formats to use like Edge Animate, Starling and Cocos2D, and adds the possibility to only add one Path as obligatory, in case that you only want to add only one thing and the document you want to parse is in the same directory or in a subdirectory inside that directory.

I think you know how to load a spritesheet but just in case:

```haxe
    var sprite:FlxSprite = new FlxSprite(X,Y);
    sprite.frames = FlxAnimateFrames.from[the name of the format youre exporting]('${PathOfTheDocument}.${extensionofthedocument}');
```

and if you're using an image that is not in the same directory but in a whole another directory, ex: the document is in `data` and your image is in `images`, you should add another field describing the Path of that image.
