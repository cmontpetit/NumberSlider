# NumberSlider
Custom view that embeds a UISlider control for updating an Int value.

The slider is divided in integer steps that increase or decrease the value using different increments. It uses various NSTimer instances to manage the increment changes, and acceleration. It still requires tweaking in the timings to make it more natural.

Here is a screenshot. Note that the label in the middle with the actual value is not part of the NumberSlideView, but is updated from the listener protocol invocations when the value changes..

![Alt text](/doc/numberSliderImage.png?raw=true "Screenshot")
