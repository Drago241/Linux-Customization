/* ============================================================
   GLava Configuration — Cinnamon Desktop Optimized
   ------------------------------------------------------------
   This configuration makes GLava act as a live wallpaper
   that sits behind desktop icons and panels, and lets you
   interact with your desktop as usual.
   ============================================================ */

/* === Module to use === */
#request mod wave

/* === Window behavior === */
#request setfloating  false      // Don't float, embed in desktop
#request setdecorated false      // Hide borders/title
#request setfocused   false      // Don’t steal focus
#request setmaximized true       // Fill the entire desktop

/* === Transparency ===
   "xroot" uses the root window pixmap for wallpaper sync.
   Works best with Cinnamon and Muffin.
*/
#request setopacity "native"

/* === Make it a true desktop visualizer ===
   Cinnamon honors the _NET_WM_WINDOW_TYPE_DESKTOP hint.
*/
#request setxwintype "desktop"

/* === Allow desktop interaction ===
   Clicks go through to icons, menus, etc.
*/
#request setclickthrough true

/* === Geometry ===
   Match your primary monitor resolution
   (use `xrandr` or Display Settings to check).
*/
#request setgeometry 0 0 1920 1080

/* === Window color (transparent) === */
#request setbg 000000

/* === Audio settings === */
#request setsource "auto"
#request setsamplerate 22050
#request setsamplesize 1024
#request setbufsize 4096
#request setmirror false
#request setinterpolate true

/* === Performance settings === */
#request setswap 1               // Enable vsync
#request setframerate 0          // No hard frame cap
#request setfullscreencheck false
#request setprintframes false

/* === OpenGL context === */
#request setversion 3 3
#request setshaderversion 330

/* === Window title (for debugging only) === */
#request settitle "GLava Desktop Visualizer"

/* === Disable deprecated options === */
#request setforcegeometry false
#request setforceraised false
#request setbufscale 1

