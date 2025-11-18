
/* Center line thickness (pixels) */
#define C_LINE 1
/* Width (in pixels) of each bar */
#define BAR_WIDTH 4
/* Width (in pixels) of each bar gap */
#define BAR_GAP 2
/* Outline color */
#define BAR_OUTLINE #262626
/* Outline width (in pixels, set to 0 to disable outline drawing) */
#define BAR_OUTLINE_WIDTH 0
/* Amplify magnitude of the results each bar displays */
#define AMPLIFY 300
/* Whether the current settings use the alpha channel;
   enabling this is required for alpha to function
   correctly on X11 with `"native"` transparency. */
#define USE_ALPHA 0
/* How strong the gradient changes */
#define GRADIENT_POWER 60
/* Bar color changes with height */
#define GRADIENT (d / GRADIENT_POWER + 1)

/* === Bar gradient color ===
   Colors transition smoothly from center to outer edge.
*/
#define COLOR mixColors(d / 400.0)

/* Gradient function (center → outward) */
vec4 mixColors(float t) {
    vec4 c1  = vec4(0.231, 0.235, 0.349, 1.0);  // #3b3c59
    vec4 c2  = vec4(0.294, 0.267, 0.392, 1.0);  // #4b4464
    vec4 c3  = vec4(0.294, 0.267, 0.392, 1.0);  // #4b4464
    vec4 c4  = vec4(0.427, 0.322, 0.463, 1.0);  // #6d5276
    vec4 c5  = vec4(0.498, 0.349, 0.494, 1.0);  // #7f597e
    vec4 c6  = vec4(0.573, 0.380, 0.518, 1.0);  // #926184
    vec4 c7  = vec4(0.643, 0.408, 0.541, 1.0);  // #a4688a
    vec4 c8  = vec4(0.714, 0.439, 0.557, 1.0);  // #b6708e
    vec4 c9  = vec4(0.784, 0.475, 0.565, 1.0);  // #c87990
    vec4 c10 = vec4(0.851, 0.510, 0.573, 1.0);  // #d98292

    vec4 colors[10] = vec4[10](c1,c2,c3,c4,c5,c6,c7,c8,c9,c10);
    float step = 1.0 / 9.0;
    int i = int(clamp(floor(t / step), 0.0, 8.0));
    float f = (t - float(i) * step) / step;
    return mix(colors[i], colors[i + 1], f);
}

/* Direction that the bars are facing, 0 for inward, 1 for outward */
#define DIRECTION 0
/* Whether to switch left/right audio buffers */
#define INVERT 0
/* Whether to flip the output vertically */
#define FLIP 0
/* Whether to mirror output along `Y = X`, causing output to render on the left side of the window */
/* Use with `FLIP 1` to render on the right side */
#define MIRROR_YX 0

