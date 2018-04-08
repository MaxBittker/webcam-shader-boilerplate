# regl-shader-error-overlay

Somewhat silly monkey-patched dev tool to render shader errors logged by regl as formatted overlays.
Ideally, this would be a plugin or option in regl itself, but this works!

![screenshot](https://i.imgur.com/B8vpErz.png)

## usage:

`npm install -S regl-shader-error-overlay`

```
import {setupOverlay} from "regl-shader-error-overlay";
setupOverlay();

//... (regl code)
```

The log statements we're targeting are logged by regl here: https://github.com/regl-project/regl/blob/master/lib/util/check.js#L233
