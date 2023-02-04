<p align="center">
    <img src="./logo.svg" width="700" alt="FlxAnimate's logo, constituting of the HaxeFlixel logo sliced into pieces and then 4 arrows pointing where the parts should be to create a result."/> 
</p>

<h1 align="center"> FlxAnimate</h1>

FlxAnimate is an open-sourced Haxe library which focuses on support all kinds of export options that Adobe Animate offers, such as Spritesheets (such as Sparrow, Json, Cocos2D, EdgeAnimate, etc.) or Texture Atlases to be supported on [HaxeFlixel](https://github.com/HaxeFlixel/flixel), a 2D game engine.

FlxAnimate prioritizes to be accurate to how it would show in a Small Web Format, specially texture atlases. 

## Support

In case of any doubts, issues or ideas for FlxAnimate and you wish to pitch them to one of our members, you can contact CheemsAndFriends on Discord as `Miss Muffin#8930`, or on Twitter as [`@CheemsnFriendos`](https://twitter.com/CheemsnFriendos), but it is preferrable on Discord in any case.

## TODO

* There are some missing filters that need to be implemented, such as:
    * BevelFilter
    * GradientGlowFilter
    * GradientBevelFilter
* The sprite to actually be merged on the rendering with flixel

* A wiki or a page to have some API stated somewhere + document functions and variables (second thing really important!)

<h1 align="center"> Installation</h1>

Currently, there are <b>two</b> ways to download FlxAnimate:


## 1. Haxelib

Haxelib is the pack manager that lets you store libraries which then you can inject code via `Project.xml`.

It is available in haxelib and you can download by typing `haxelib install flxanimate` on your command prompt.

## 2. Git

Git is an open-sourced version control system designed to handle every type of project, in this case, FlxAnimate. You should check first of all if you have [Git](https://git-scm.com) 
installed before typing `haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate` on your terminal or command prompt.
**WARNING**: This version may be broken or unstable cos it is on a development point, not ready to release <b>Download it at your own precaution!</b>


# Texture Atlas

**WARNING:** This repository **DOES NOT** transform texture atlases into a spritesheet! If you wish to use this, It's better to use [Smokey555's repo](https://github.com/Smokey555/Flixel-TextureAtlas)

A texture atlas is a format provided by Adobe Animate in 2017 which provides an accurate depiction of an Animate animation, in other words, it would be something similar to work with actual values from a SWF file.
When using it, it will export at least 3 files:

- `Animation` - Details the structure of the animation, from sprites and matrices to symbols, color effects and filters.
- `spritemap` - The sprites used in the texture atlas. **WARNING**: Depending on what version of Animate you're using, it may vary to several files of the same type. Ex: spritemap1, spritemap2, etc.

## Usage

To use FlxAnimate's texture support, you will need to create a new instance of FlxAnimate, as you would do with FlxSprite.

```haxe
var character:FlxAnimate = new FlxAnimate(X, Y, PathToAtlas);
```
**WARNING:** The Path has to be from the folder which the texture atlas is in, NOT the path of the animation file, or the spritemap files.

## SpriteSheet

There are several formats that Adobe Animate offers to use for different kinds of uses, but mostly for storing animations without having to do big calculations, unlike Texture Atlases.
To use a spritesheet with the format that Animate offers, you would need to type the name of the Spritesheet, excluding the version if it has several.

For example:

```haxe
    var sprite:FlxSprite = new FlxSprite(X,Y);
    sprite.frames = FlxAnimateFrames.fromCocos2D(Path);
```