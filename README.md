![](etc/EA.png)

#### ver 1.1

_The library doesn't use any private APIs - apps using it should be fine for release on the App Store._

<table width="100%">
<tr>
<td width="300">
<a href="#intro">Intro</a><br>
<a href="#layers">Layer Animations</a><br>
<a href="#springs">Spring Layer Animations</a><br>
<a href="#chains">Chain Animations</a><br>
<a href="#stop">Cancel Chain Animations</a><br>
</td>
<td width="300">
<a href="#installation">Installation</a><br>
<a href="#credit">Credit</a><br>
<a href="#license">License</a><br>
<a href="#version">Version History</a>
</td>
</tr>
</table>

<a name="intro"></a>
Intro
========

`UIView.animateWithDuration:animations:` is really easy to use and you're so familiar with its syntax that you often want it to do just a bit more for you automatically. But it doesn't and you need to import *Bloated.framework* by *Beginner Ninja Coder* in order to make a bit more advanced animations than what `animateWithDuration:animations:` allows you to.

**EasyAnimation** extends what UIKit offers in terms of animations and makes your life much easier because you can do much more without learning some perky new syntax.

### Versions

Easy Animation is _Swift 3.0_. 

If you are looking for a Swift 2 version check [Easy Animation 1.0.5](https://github.com/icanzilb/EasyAnimation/releases/tag/1.0.5).

<a name="layers"></a>
Easy Layer Animations
========

**EasyAnimation** allows you to animate your layers straight from `animate(duration:animations:...)`. No more `CABasicAnimation` code for you. Just adjust the properties of your layers from within the `animations` block and **EasyAnimation** will take care of the rest:
<table width="100%">
<th>CoreAnimation (before)</th>
<tr>
<td valign="top">
<pre lang="Swift">
    let anim = CABasicAnimation(keyPath: "position.x")
    anim.fromValue = 100.0
    anim.toValue = 200.0
    anim.duration = 2.0
    view.layer.addAnimation(anim, forKey: nil)
</pre>
</td>
</tr>
</table>
<table width="100%">
<th>EasyAnimation (after)</th>
<tr>
<td valign="top">
<pre lang="Swift">
    UIView.animate(duration: 2.0, animations: {
        self.view.layer.position.x = 200.0
    })
</pre>
</td>
</tr>
</table>

![](etc/moveX.gif)

(OK, this example actually works fine also without EasyAnimation but I still keep it here for illustrative purpose)

Or if you need to specify delay, animation options and/or animation curve:

<table width="100%">
<th>CoreAnimation (before)</th>
<tr>
<td valign="top">
<pre lang="Swift">
    let anim = CABasicAnimation(keyPath: "position.x")
    anim.fromValue = 100.0
    anim.toValue = 200.0
    anim.duration = 2.0
    anim.fillMode = kCAFillModeBackwards
    anim.beginTime = CACurrentMediaTime() + 2.0
    anim.timingFunction = CAMediaTimingFunction(name: 
        kCAMediaTimingFunctionEaseOut)
    anim.repeatCount = Float.infinity
    anim.autoreverses = true
    view.layer.addAnimation(anim, forKey: nil)
</pre>
</td>
</tr>
</table>
<table width="100%">
<th>EasyAnimation (after)</th>
<tr>
<td valign="top">
<pre lang="Swift">
    UIView.animate(duration: 2.0, delay: 2.0, 
        options: [.repeat, .autoreverse, .curveEaseOut], 
        animations: {
        self.view.layer.position.x += 200.0

        // let's add more animations 
        // to make it more interesting!
        self.view.layer.cornerRadius = 20.0
        self.view.layer.borderWidth = 5.0
    }, completion: nil)
</pre>
</td>
</tr>
</table>

![](etc/corners.gif)

And if you want to execute a piece of code after the animation is completed - good luck setting up your animation delegate and writing the delegate methods. 

With **EasyAnimation** you just put your code as the `completion` parameter value and **EasyAnimation** executes it for you when your animation completes.

<a name="springs"></a>

Spring Layer Animations
========
One thing I really missed since iOS9 when using CoreAnimation and `CABasicAnimation` was that there was no easy way to create spring animations. Luckily a handy library called `RBBAnimation` provides an excellent implementation of spring animations for layers - I translated the code to Swift and included `RBBSpringAnimation` into `EasyAnimation`. 

Easy Animation takes care to use the new in iOS9 spring animation class `CASpringAnimation` when your app runs on iOS9 or higher and falls back to `RBBSpringAnimation` when your app runs on iOS8.

Here's how the code to create a spring animation for the layer position, transform and corner radius looks like:

<table width="100%">
<th>EasyAnimation</th>
<tr>
<td valign="top">
<pre lang="Swift">
    UIView.animate(duration: 2.0, delay: 0.0, 
      usingSpringWithDamping: 0.25, 
      initialSpringVelocity: 0.0, 
      options: [], 
      animations: {
        self.view.layer.position.x += 200.0
        self.view.layer.cornerRadius = 50.0
        self.view.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0)
    }, completion: nil)
</pre>
</td>
</tr>
</table>

![](etc/spring.gif)

[Sam Davies](https://github.com/sammyd) collaborated on the spring animations code. Thanks a ton - I couldn't have figured this one on my own!

<a name="chains"></a>

Chain Animations
========

`animate(duration:animations:..)` is really handy but chaining one animation after another is a major pain (especially if we are talking about more than 2 animations).

**EasyAnimation** allows you to use a method to just chain two or more animations together.  Call `animateAndChain(duration:delay:options:animations:completion:)` and then chain to it more animations. Use `animate(duration:animations...)` or any other method to create chained animations.

<table width="100%">
<th>EasyAnimation</th>
<tr>
<td valign="top">
<pre lang="Swift">
    UIView.animateAndChain(duration: 1.0, delay: 0.0, 
      options: [], animations: {
        self.view.center.y += 100
    }, completion: nil).animate(duration: 1.0, animations: {
        self.view.center.x += 100
    }).animate(duration: 1.0, animations: {
        self.view.center.y -= 100
    }).animate(duration: 1.0, animations: {
        self.view.center.x -= 100
    })
</pre>
</td>
</tr>
</table>

![](etc/chain.gif)

*Yes - that works, give it a try in your project :]*

This code will animate the view along a rectangular path - first downwards, then to the right, then up, then to the initial point where the animation started.

What a perfect oportunity to repeat the animation and make the animation run continuosly! Add `options` parameter to the last `animate(duration:...` in the chain and turn on the `.repeat` option. 

This will make the whole chain (e.g. the 4 animations) repeat continuously.

If you want to pause between any two animations in the chain - just use the `delay` parameter and it will all just work.

**Note**: `animateAndChain` does not create a serial queue to which you could add animations at any time. You schedule your animations once with one call like the example above and it runs on its own, you can't add or remove animations to and from the sequence.

<a name="stop"></a>

Cancel Chain Animations
========

If you have a repeating (or a normal) chain animation on screen you can cancel it at any time. Just grab hold of the animation object and call `cancelAnimationChain` on it any time you want.

<pre lang="Swift">
let chain = UIView.animateAndChain(duration: 1.0, delay: 0.0,
    options: [], animations: {
        self.square.center.y += 100
    }, completion: nil).animate(duration: 1.0, animations: {
  [... the rest of the animations in the chain]
</pre>

<pre lang="Swift">
chain.cancelAnimationChain()
</pre>

If you want to do some cleanup after the animation chain is cancelled provide a block of code to the `cancelAnimationChain` method:

<pre lang="Swift">
chain.cancelAnimationChain({
  self.myView.center = initialPosition
  //etc. etc.
})
</pre>


The animation will not stop immediately but once it completes the current step of the chain it will stop and cancel all scheduled animations in this chain.

<a name="installation"></a>

Installation
========

* __CocoaPods__: Add to your project's **Podfile**:

`pod 'EasyAnimation'`

* __Carthage__: If you can help with Cartage support let me know.

* __Source code__: To install with the source code - clone this repo or download the source code as a zip file. Include all files within the `EasyAnimation` folder into your project.

<a href="credit"></a>

Credit
========

Author: **Marin Todorov**

* [http://www.underplot.com](http://www.underplot.com)
* [https://twitter.com/icanzilb](https://twitter.com/icanzilb)

More about Marin:

<table>
<tr>
<td>
<a href="http://www.ios-animations-by-tutorials.com/"><img src="http://www.underplot.com/images/thumbs/iat.jpg" width="170"><br>
<b>iOS Animations by Tutorials</b>, Author</a>
</td>
<td>
<a href="http://www.ios-animations-by-emails.com/"><img src="http://www.underplot.com/images/thumbs/ios-animations-by-emails.jpg" width="170"><br>
iOS Animations by Emails Newsletter, Author</a>
</td>
</tr>
</table>

Includes parts of [RBBAnimation](https://github.com/robb/RBBAnimation) by [Robert Böhnke](https://github.com/robb). The code is translated from Objective-C to Swift by Marin Todorov.

Collaborator on the spring animation integration: [Sam Davies](https://github.com/sammyd).

<a name="license"></a> 

License
========
`EasyAnimation` is available under the MIT license. See the LICENSE file for more info.

`RBBAnimation` license: [https://github.com/robb/RBBAnimation/blob/master/LICENSE](https://github.com/robb/RBBAnimation/blob/master/LICENSE)

<a name="version"></a>

To Do
=========

* `.autoreverse` for chain animations (if possible)
* add support for keyframe animation along the path via a custom property
  
Version History
========
 * 1.1 - Xcode 8
* 1.0.5 - Xcode 7.3 compatibility 
* 1.0.4 - Swift 3 compatibility changes
* 1.0.2 - Fixes openGL view crashes for everyone
* 1.0.1 - Bug fixes
* 1.0 - Swift 2.0 and iOS9
* 0.7 - round of bug fixes and a number of improvements
* 0.6 - first beta version
