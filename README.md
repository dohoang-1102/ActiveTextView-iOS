ActiveTextView
=========

This project consists of a few examples demonstrating how to draw selectable multicolored text in iOS.

Summary
-----------

ActiveTextView was developed because drawing multi-colored selectable text on iOS is a pain. The sources offered here won't likely be a perfect drop in solution for developers requiring this functionality, but we feel it demonstrates how to accomplish much of the most desired functionality with respect to multi colored text rendering. ActiveTextView works both ARC and non-ARC build enviroments.

The following image is a simple example of what ActiveTextView can do:

![Image](http://cl.ly/3s410L1d1X2t110u3F3L/ActiveTextViewUnSelected.png)

You can specify a string to draw, as well as substrings containing different formatting and color.

![Image](http://cl.ly/351W2a1a0K2i340H3R2y/ActiveTextViewSelected1.png)

In addition to specifying custom formatting so specific regions of your text, you can also specify handlers that will get invoked when the user taps on text within a specific region:

![Image](http://cl.ly/2j0c1a24381J3F0i2m42/Screen%20Shot%202012-05-08%20at%204.51.36%20PM.png)

ActiveTextView also demonstrates three different techniques for having the text visually respond to user taps:

1. The color of the string can be adjusted to indicate that something has been tapped. (Useful for selecting URLs, for example).
2. The bounding region of the text can be used to draw a rectangle (or any other shape) behind the text statically.
3. The bounding region of the text can be used to draw a rectangle behind the text, but this rectangle can animate between successive positions through the use of the SlidingTextSelectorView class:

![Image](http://cl.ly/3v1j313a1m1M210T2B1e/TextSelectorSlide.png)



Known Issues
--------------

Currently, when highlighting selected regions (either with the SlidingTextSelector, or the static background) ActiveTextView doesn't handle regions that span multiple lines.


  
    
