<p align="center">
    <img src="./logo.svg" width="500" alt="FlxAnimate's logo, constituting of the HaxeFlixel logo sliced into pieces and then 4 arrows pointing where the parts should be to create a result."/> 
</p>

# FlxAnimate

FlxAnimate is an open source plugin focused on parsing spritesheets and implementing Texture Atlases exported by the computer animation program [Adobe Animate](https://www.adobe.com/es/products/animate.html) (formerly known as Adobe Flash) on [HaxeFlixel](https://haxeflixel.com). <a href="https://helpx.adobe.com/animate/using/create-sprite-sheet.html"> <sub>More Information</sub> </a>

It can be useful when you need to export spritesheets that are not supported by the game engine, such as Cocos 2D, Starling, Sparrow v1, among others. Not to mention the possibility to play efficiently Texture Atlases on runtime, while mimicking Animate's structure as much fidelity as possible.

## Questions/Support

In case that you have any questions or problems about the project, you can contact CheemsAndFriends on: 

<div align="center">
&ensp;<a href="https://discord.com"><img src="https://assets-global.website-files.com/6257adef93867e50d84d30e2/636e0a69f118df70ad7828d4_icon_clyde_blurple_RGB.svg" width="250px"/></a>
&emsp;&emsp;&emsp;&emsp;&emsp;<a href="https://twitter.com/CheemsnFriendos/"><img src="https://upload.wikimedia.org/wikipedia/commons/6/6f/Logo_of_Twitter.svg" width="251px"/></a>
<p>(as <b>cheemsnfriends</b>) &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;(as <a href="https://twitter.com/CheemsnFriendos/"><b>@CheemsnFriendos</b><a/>) </p>
</div>


# Limitations

* No support on symbols that require 3D transformation ([See More](https://en.wikipedia.org/wiki/Transformation_matrix#Examples_in_3D_computer_graphics))

## TODO

* Blend mode support for shader based blends.
* Support on layer masks.
* A wiki or website API related + samples to tweak on. Something similar as [HaxeFlixel's demos](https://haxeflixel.com/demos) and [HaxeFlixel's API](https://api.haxeflixel.com).

# How to install?

## 1. Haxelib

The Haxe Library Manager (also known as Haxelib) is the manager that lets you use, download and upload libraries that are inside Haxe's ecosystem.

you can download it by typing `haxelib install flxanimate` on your terminal or command prompt.

## 2. Git

Git is an open-sourced version control system designed to handle every type of project in Github, in this case, FlxAnimate. You should check first of all if you have [Git](https://git-scm.com) 
installed before typing `haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate` on your terminal or command prompt.

# How to use it?

There are two usages that you can apply to FlxAnimate: One is the Texture Atlas export and the Spritesheet export.

## Texture Atlas

**WARNING:** This repository **DOES NOT** transform texture atlases into spritesheets! If you wish to use this, It's better to use [Smokey555's repo](https://github.com/Smokey555/Flixel-TextureAtlas).

In order to use FlxAnimate's texture atlas support, you will need to create a new instance of FlxAnimate, as you would do with FlxSprite.

```haxe
var character:FlxAnimate = new FlxAnimate(X, Y, "Path/To/Atlas");
```
`Path/To/Atlas` has to be from the folder that you exported the atlas texture atlas with, not with any of the contents in there.

Example:

✅ Correct Path:
```haxe
var ninja_girl:FlxAnimate = new FlxAnimate(X, Y, "assets/images/ninja-girl");
```

❎ Incorrect Path:

```haxe
var ninja_girl:FlxAnimate = new FlxAnimate(X, Y, "assets/images/ninja-girl/Animation.json"); // This also applies with spritemaps!
```

## Spritesheet

There are several formats that Adobe Animate offers to use for different kinds of uses, but mostly for storing animations without having to do big calculations, unlike Texture Atlases.
To use a spritesheet with the format that Animate offers, you would need to type the name of the Spritesheet, excluding the version if it has several.

For example:

```haxe
    var sprite:FlxSprite = new FlxSprite(X,Y);
    sprite.frames = FlxAnimateFrames.fromCocos2D(Path);
```