/* center radius (pixels) */
#define C_RADIUS 128
/* center line thickness (pixels) */
#define C_LINE 2
/* outline color */
#define OUTLINE #333333
/* number of bars (use even values for best results) */
#define NBARS 180
/* width (in pixels) of each bar*/
#define BAR_WIDTH 3.5
/* outline color */
#define BAR_OUTLINE OUTLINE
/* outline width (in pixels, set to 0 to disable outline drawing) */
#define BAR_OUTLINE_WIDTH 0
/* Amplify magnitude of the results each bar displays */
#define AMPLIFY 300

/* === Radial gradient color ===
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

/* Angle (in radians) for how much to rotate the visualizer */
#define ROTATE (PI / 2)
/* Whether to switch left/right audio buffers */
#define INVERT 0
/* Aliasing factors */
#define BAR_ALIAS_FACTOR 1.2
#define C_ALIAS_FACTOR 1.8
/* Offset (Y) of the visualization */
#define CENTER_OFFSET_Y 0
/* Offset (X) of the visualization */
#define CENTER_OFFSET_X 0

/* Gravity step, override from `smooth_parameters.glsl` */
#request setgravitystep 5.0

/* Smoothing factor, override from `smooth_parameters.glsl` */
#request setsmoothfactor 0.02

