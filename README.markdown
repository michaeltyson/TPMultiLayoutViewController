TPMultiLayoutViewController
===========================

A drop-in UIViewController subclass that automatically manages switching between different view layouts
for portrait and landscape orientations, without the need to maintain view state across two different
view hierarchies.

## The Problem

 - You want to support portrait and landscape modes in your app.
 - Having just one view layout for both portrait and landscape doesn't give good results.

## The Conventional Solution: Double Handling

 - Create two distinct view hierarchies: one for portrait and one for landscape.
 - On orientation change, set `this.view` to either your portrait view, or your landscape view.
 - On load, perform your initialisation on both views: *Big Overhead*.
 - Whenever your view/app state changes, sync the state across both views: *Big Overhead*.

## An Easier Solution: Layout Templating

 - Create two distinct view hierarchies: one for portrait and one for landscape.
 - Extract just the layout information from the two view versions: use the original two view hierarchies as a *layout template*.
 - Maintain one single view hierarchy: no double handling, no state syncing.
 - On orientation change, simply apply the layout information we extracted to our single view hierarchy, to achieve the new layout.
 
In summary, we skip the double handling by keeping just one view, not two views we need to sync.  When the orientation changes, we just
rearrange the view, using the layout we extracted from our original two views.
 
## Usage

 1. Set the superclass for your view controller to TPMultiLayoutViewController.
 2. In Interface Builder, create two different views: one for portrait orientation, and one for landscape orientation.
 3. Attach your portrait orientation root view to the "portraitView" outlet, and the landscape orientation root view
    to the "landscapeView" outlet.
 4. Attach one of the views (whichever you prefer) to the "view" outlet, and connect
    any actions and outlets from that view.

## Notes

 - Currently, only `frame`, `bounds`, `hidden` and `autoresizingMask` attributes are assigned, but this can be easily extended.  See `attributesForView:` and `applyAttributes:toView:` for details.
 - Both layouts should have the same hierarchical structure.
 - Views are matched to their counterparts in the other layout by searching for similarities, in the following order:
    1. Tag
    2. Class, target and action (for UIControl)
    3. Title or image (for UIButton)
    4. Title (for UILabel)
    5. Text or placeholder (for UITextField)
    6. Class
    
  If you experience odd behaviour, check the log for "Couldn't find match..." messages.  If a view cannot be matched to its counterpart, try setting the same tag for both views.

## Licence

This code is licensed under the terms of the MIT license.

Michael Tyson  
A Tasty Pixel