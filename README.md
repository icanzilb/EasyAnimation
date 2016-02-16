![](<etc/EA.png>)

#### ver 1.0.4

*The library doesn't use any private APIs - apps using it should be fine for
release on the App Store.*

Intro Layer Animations Spring Layer Animations Chain Animations Cancel Chain
Animations

Installation Credit License Version History

Intro ========

`UIView.animateWithDuration:animations:` is really easy to use and you're so
familiar with its syntax that you often want it to do just a bit more for you
automatically. But it doesn't and you need to import *Bloated.framework* by
*Beginner Ninja Coder* in order to make a bit more advanced animations than what
`animateWithDuration:animations:` allows you to.

**EasyAnimation** extends what UIKit offers in terms of animations and makes
your life much easier because you can do much more without learning some perky
new syntax.

### Versions

Easy Animation 1.0+ is written in *Swift 2.0*. If you are looking for a Swift
1.2 version check [Easy Animation
0.7](<https://github.com/icanzilb/EasyAnimation/releases/tag/0.7.0>).

Easy Layer Animations ========

**EasyAnimation** allows you to animate your layers straight from
`animateWithDuration:animations:`. No more `CABasicAnimation` code for you. Just
adjust the properties of your layers from within the `animations` block and
**EasyAnimation** will take care of the rest:

CoreAnimation (before)

EasyAnimation (after)

![](<etc/moveX.gif>)

(OK, this example actually works fine also without EasyAnimation but I still
keep it here for illustrative purpose)

Or if you need to specify delay, animation options and/or animation curve:

CoreAnimation (before)

EasyAnimation (after)

![](<etc/corners.gif>)

And if you want to execute a piece of code after the animation is completed -
good luck setting up your animation delegate and writing the delegate methods.

With **EasyAnimation** you just put your code as the `completion` parameter
value and **EasyAnimation** executes it for you when your animation completes.

# Spring Layer Animations

One thing I really missed since iOS9 when using CoreAnimation and
`CABasicAnimation` was that there was no easy way to create spring animations.
Luckily a handy library called `RBBAnimation` provides an excellent
implementation of spring animations for layers - I translated the code to Swift
and included `RBBSpringAnimation` into `EasyAnimation`.

Easy Animation takes care to use the new in iOS9 spring animation class
`CASpringAnimation` when your app runs on iOS9 or higher and falls back to
`RBBSpringAnimation` when your app runs on iOS8.

Here's how the code to create a spring animation for the layer position,
transform and corner radius looks like:

EasyAnimation

![](<etc/spring.gif>)

[Sam Davies](<https://github.com/sammyd>) collaborated on the spring animations
code. Thanks a ton - I couldn't have figured this one on my own!

# Chain Animations

`animateWithDuration:animations:` is really handy but chaining one animation
after another is a major pain (especially if we are talking about more than 2
animations).

**EasyAnimation** allows you to use a method to just chain two or more
animations together. Call
`animateAndChainWithDuration:delay:options:animations:completion:` and then
chain to it more animations. Use `animateWithDuration:animations` or any other
method to create chained animations.

EasyAnimation

![](<etc/chain.gif>)

*Yes - that works, give it a try in your project :]*

This code will animate the view along a rectangular path - first downwards, then
to the right, then up, then to the initial point where the animation started.

What a perfect oportunity to repeat the animation and make the animation run
continuosly! Add `options` parameter to the last `animateWithDuration...` in the
chain and turn on the `.Repeat` option.

This will make the whole chain (e.g. the 4 animations) repeat continuosly.

If you want to pause between any two animations in the chain - just use the
`delay` parameter and it will all just work.

**Note**: `animateAndChainWithDuration` does not create a serial queue to which
you could add animations at any time. You schedule your animations once with one
call like the example above and it runs on its own, you can't add or remove
animations to and from the sequence.

# Cancel Chain Animations

If you have a repeating (or a normal) chain animation on screen you can cancel
it at any time. Just grab hold of the animation object and call
`cancelAnimationChain` on it any time you want.

If you want to do some cleanup after the animation chain is cancelled provide a
block of code to the `cancelAnimationChain` method:

The animation will not stop immediately but once it completes the current step
of the chain it will stop and cancel all scheduled animations in this chain.

# Installation

-   **CocoaPods**: Add to your project's **Podfile**:

`pod 'EasyAnimation'`

-   **Carthage**: I'm being told the repo supports now Carthage integration.

-   **Source code**: To install with the source code - clone this repo or
    download the source code as a zip file. Include all files within the
    `EasyAnimation` folder into your project.

# Credit

Author: **Marin Todorov**

-   <http://www.underplot.com>

-   <https://twitter.com/icanzilb>

More about Marin:

iOS Animations by Tutorials, Author

iOS Animations by Emails Newsletter, Author

Includes parts of [RBBAnimation](<https://github.com/robb/RBBAnimation>) by
[Robert Böhnke](<https://github.com/robb>). The code is translated from
Objective-C to Swift by Marin Todorov.

Collaborator on the spring animation integration: [Sam
Davies](<https://github.com/sammyd>).

# License

`EasyAnimation` is available under the MIT license. See the LICENSE file for
more info.

`RBBAnimation` license:
<https://github.com/robb/RBBAnimation/blob/master/LICENSE>

# To Do

-   add `CALayer.animateWithDuration:animations:`.. for the people who want to
    use different methods for view and layer animations

-   `.Autoreverse` for chain animations (if possible)

-   add support for keyframe animation along the path via a custom property

# Version History

-   1.0.4 - Swift 3 compatibility

-   1.0.2 - Fixes opengl view crashes for everyone

-   1.0.1 - Bug fixes

-   1.0 - Swift 2.0 and iOS9

-   0.7 - round of bug fixes and a number of improvements

-   0.6 - first beta version
