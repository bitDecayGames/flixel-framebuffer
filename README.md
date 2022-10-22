# Flixel Frame Buffer

This repo shows a way I found to get a "frame buffer" for a full-screen shader.
The particular use-case here is a dynamic lighting shader, but the same concept here could be used for any shader that would benefit from secondary `BitmapData` as input.

## TOC
- [Concept](#concept)
- [Example](#example)
- [Implementation](#implementation)
  - [Controls](#controls)
- [Shader](#shader)
- [Limitations](#limitations)

## Concept

![Concept](./art/concept.png)

This dynamic lighting shader needs a few pieces as input:

1. Unshaded game render
    * All the base sprites on screen in their raw state in the game as seen by the camera
    * This comes from the standard `camera` on the FlxState
1. Additional graphical information. Each layer here has a special camera that only 'sees' the correct assets for the type of render being built
    1. Normal map render
    1. Height map render
1. Lighting information
    * Any lights in the environment and their position relative to the current view of the camera
    * Ambient lighting to provide a base level of illumination
    * **NOTE:** As lights move or change, or the camera scrolls, the shader needs to be updated

The shader code itself will consume all of this information and provide the final rendered frame to show on screen.

## Example (Dyanmic Lighting Shader)

**Base Unshaded Sprite** - The underlying unshaded rotating diamond sprite sheet

![Unshaded](./assets/images/diamond.png)

**Normal Map** - This one was crafted by hand, but there are various tools out there to help with creating normal maps.

![Normal Map](./assets/images/diamond_norm.png)
> * An interesting tool I stumbled across while building this repo is [Laigter on itch.io](https://azagaya.itch.io/laigter), which is available as a "Name your own price" tool for creating normal maps along with other image data for 2D sprites.

**Height Map** - This map uses two of the color channels to produce a range of height that this pixel occupies along the z-axis. The green represents the lower bound, and red represents the upper bound.

![Height Map](./assets/images/diamond_height.png)

**Post Shader** - The final product with the animation playing and two lights added into the scene.

![Shaded](./art/octahedron_shadow.gif)

> * Note shadow is effectively cast from a 3-dimensional object and shows both a top and bottom point.

There is some artifacting happening in the form of miscolored pixels on the faces of the octahedron due to how the shadows are being calculated. I plan to address this. The shadows themselves are also not as crisp as I would like.

## Flixel Implementation

The idea here is to make use of the capabilities of `FlxCamera` to render our composite images that the Shader will use.

The standard Flixel code path renders all cameras sequentially with no way to add processing between different camera render calls. To get around this, I make use of a second `CameraFontEnd`. This is a little hacky, but this lets us render our normal map composite image and pass that data into our shader so that it is accurate to the composite image of our unshaded sprites.
> **_NOTE:_** Just using the cameras as Flixel does by default would yield a composite normal image that is always one frame behind what the state of the game currently is.

There are a few uses of `@access` here in order to be able to render cameras in the order we want. The key here is that we actually render the normal map composite as part of the `LightingState`'s `draw()` function so that when the base camera has the proper normal data before it is rendered.

* Use of plain `FlxSprite` is fine: no errors occurs. The shader included in this example project treats them as a flat surface facing directly at the camera.

### Controls

* `LEFT` and `RIGHT` arrows allow switching between different test States (note that not all States support all the other controls)
* `LEFT CLICK` and `RIGHT CLICK` moves the cameras
* `SCROLL WHEEL` while holding a mouse button changes the height of the given camera
* `SPACE` will allow you to cycle through cameras to see what it is rendering.
* `M` creates more objects
* `SHIFT` will shake the camera

## Shader

The Shader code in `LightingShader.hx` uses three input images
1. The base sprites: The standard `FlxCamera` view of the unshaded base sprites
2. The normal map data: The composite image from a `FlxCamera` that only sees the normal map sprites
3. The height map data: The composite image from a `FlxCamera` that only sees the height map sprites

In theory, as many images can be fed in as may be needed to achieve the desired effect.

## Limitations

* `LightingState` tries to automate sprite management as best it can. However some things are tedious to handle transparently, such as setting `pixelPerfectRender` on the underlying normal sprite. There will need to be some expansion on alignment of properties between the base sprite and the underlying normal. As of this example implementation, anything _other_ than the `x` and `y` coordinates will have to be manually kept in sync.
* Camera zoom is not currently supported.
> **NOTE:** As this has some heavy-handed workarounds to how cameras are managed within HaxeFlixel, tread carefully when manipulating cameras (such as adding new cameras to a state), as it can cause things to stop rendering properly. I'll be documenting these alongside the code as I uncover and find solutions to them.
