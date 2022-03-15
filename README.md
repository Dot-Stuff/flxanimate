![](./logo.svg)

# FlxAnimate

Run `haxelib install https://github.com/Dot-Stuff/flxanimate.git` to install FlxAnimate.

A way to introduce texture atlases through your flixel projects.

FlxAnimate introduces a way to add single animations through the texture atlas from the Adobe Animate, making the animations be more modifiable through the png so instead of the whole animation stamped in sheets, it's a recap of all the drawings which will be used for the animation later on.
Right now it's in development, so it's very possible the name functions, variables and/or classes will change on the future.

# How to use it
It's actually really simple to use! You need to call FlxAnimate, as you would do with like pretty much an FlxSprite
```haxe
var char = new FlxAnimate(x,y, 'Path');
```
There's also a settings variable, this is used just in case you want to initialize the variables with a Json or something like that, or you don't want to add 70 different variables checking about the stuff and blablabla.
You can add your own animations too!
**AT THE MOMENT** you can add animations thro single symbols and with indices, We are planning to add animations with smashing the symbols thro layers and by frame prefixes.
Adding animations with symbols:
```haxe
char.anim.addBySymbol(animationName, SymbolName, X, Y, framerate);
```
Adding animations with indices:
```haxe
char.anim.addByAnimIndices(animationName, [0,1,2,3], framerate);
```
**WARNING:** Adding animations by indices affects only with the exported symbol, the main animation, do not try with different symbols! it won't work!

## TODO
There's nothing much... maybe some adding animations thingy, like with prefixes and retouching stuff, but nothing more than that.

# Support
You don't have to do it, but if you feel like you want to support this repo, Please check my Discord `Miss Muffin#8930` And send an issue of what's it's giving you problems
