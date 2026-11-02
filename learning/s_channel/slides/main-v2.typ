// BOχEFT and its application to X_b: the slides in a single file.
// Build: typst compile main.typ   (Typst 0.15; fetches @preview/cetz:0.4.2 on first use)

#import "@preview/cetz:0.4.2"

#let gray-text = luma(105)
#let rule-gray = luma(160)
#let key-stroke = rgb(0%, 0%, 45%) // xcolor blue!45!black, the notes' keybox frame
#let key-fill = rgb(97%, 97%, 100%) // xcolor blue!3, the notes' keybox background

/// Page and text setup; apply with `#show: deck`.
#let deck(body) = {
  set page(
    paper: "presentation-16-9",
    margin: (x: 1.5cm, top: 1.0cm, bottom: 1.25cm),
    footer: context {
      let n = counter(page).get().first()
      if n > 1 { align(right, text(size: 11pt, fill: gray-text)[#n]) }
    },
  )
  set text(font: "New Computer Modern", size: 18pt, lang: "en")
  set par(leading: 0.8em, spacing: 1.0em)
  set list(spacing: 0.9em, indent: 0.3em)
  show math.equation.where(block: true): set block(above: 0.85em, below: 0.85em)
  set table(stroke: none, inset: (x: 0.45em, y: 0.3em))
  body
}

/// PDF navigation entry without visible content or added layout space.
#let slide-bookmark(title) = {
  show heading: _ => []
  heading(level: 1, numbering: none, outlined: false, bookmarked: true, title)
}

/// One slide: bold title over a thin gray rule, then the body. `refs` is set
/// in small gray type at the bottom right.
#let slide(title, refs: none, body) = {
  pagebreak(weak: true)
  slide-bookmark(title)
  block(below: 0.4em, text(size: 1.3em, weight: "bold", title))
  line(length: 100%, stroke: 0.6pt + rule-gray)
  v(0.15em)
  body
  if refs != none {
    place(bottom + right, text(size: 11pt, fill: gray-text, refs))
  }
}

#let title-slide(title, author, affiliation) = align(center + horizon, {
  slide-bookmark(title)
  text(size: 1.75em, weight: "bold", title)
  v(1.4em)
  text(size: 1.1em, author)
  v(0.5em)
  text(size: 0.8em, fill: gray-text, affiliation)
})

/// Key result, framed like the notes' keybox.
#let keybox(body) = align(center, block(
  stroke: 0.6pt + key-stroke,
  fill: key-fill,
  radius: 2pt,
  inset: (x: 0.8em, y: 0.5em),
  breakable: false,
  body,
))

/// Small gray caption under a figure.
#let caption(body) = align(center, text(size: 12pt, fill: gray-text, body))

// booktabs-style table rules
#let toprule = table.hline(stroke: 0.9pt)
#let midrule = table.hline(stroke: 0.5pt)
#let bottomrule = table.hline(stroke: 0.9pt)

// Dirac notation and spectroscopic labels.
#let ket(x) = $lr(|#x chevron.r)$
#let bra(x) = $lr(chevron.l #x|)$
#let braket(a, b) = $lr(chevron.l #a mid(|) #b chevron.r)$
#let mel(a, o, b) = $lr(chevron.l #a mid(|) #o mid(|) #b chevron.r)$
#let pw(s, l, j) = $attach(#l, tl: #s, br: #j)$
#let um = math.class("unary", sym.minus)

// ------------------------------------------------------------------ plots (cetz)

/// Tick label with `digits` decimals and a real minus sign.
#let tick-label(v, digits) = {
  let parts = str(calc.round(calc.abs(v), digits: digits)).split(".")
  let frac = if parts.len() > 1 { parts.at(1) } else { "" }
  let s = if digits == 0 { parts.at(0) } else { parts.at(0) + "." + frac + "0" * (digits - frac.len()) }
  if v < 0 { $-#s$ } else { $#s$ }
}

/// Framed axes of `size` (cm) for a line plot. `body(xy)` returns cetz drawing
/// commands; `xy(x, y)` maps data coordinates to the canvas.
#let line-plot(
  size: (12, 7),
  x-range: (0, 1),
  y-range: (0, 1),
  x-ticks: (),
  y-ticks: (),
  x-digits: 0,
  y-digits: 0,
  x-label: none,
  y-label: none,
  y-label-gap: 1.3,
  tick-size: 12pt,
  label-size: 14pt,
  body,
) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let (w, h) = size
  let (x0, x1) = x-range
  let (y0, y1) = y-range
  let xy(x, y) = ((x - x0) / (x1 - x0) * w, (y - y0) / (y1 - y0) * h)
  body(xy)
  rect((0, 0), (w, h), stroke: 0.6pt)
  for t in x-ticks {
    let x = xy(t, y0).at(0)
    line((x, 0), (x, 0.12), stroke: 0.6pt)
    content((x, -0.12), text(size: tick-size, tick-label(t, x-digits)), anchor: "north")
  }
  for t in y-ticks {
    let y = xy(x0, t).at(1)
    line((0, y), (0.12, y), stroke: 0.6pt)
    content((-0.12, y), text(size: tick-size, tick-label(t, y-digits)), anchor: "east")
  }
  if x-label != none {
    content((w / 2, -0.12 - 1.5 * tick-size / 1cm), text(size: label-size, x-label), anchor: "north")
  }
  if y-label != none { content((-y-label-gap, h / 2), text(size: label-size, y-label), angle: 90deg) }
})

/// Pieces of a polyline (array of (x, y)) with y-min ≤ y ≤ y-max, cut exactly at the edges.
#let clip-y(points, y-min, y-max) = {
  let inside(p) = p.at(1) >= y-min and p.at(1) <= y-max
  let cut(a, b) = {
    let y = if calc.max(a.at(1), b.at(1)) > y-max { y-max } else { y-min }
    (a.at(0) + (y - a.at(1)) / (b.at(1) - a.at(1)) * (b.at(0) - a.at(0)), y)
  }
  let pieces = ()
  let piece = ()
  let prev = none
  for p in points {
    if prev != none and inside(p) != inside(prev) {
      piece.push(cut(prev, p))
      if not inside(p) {
        pieces.push(piece)
        piece = ()
      }
    }
    if inside(p) { piece.push(p) }
    prev = p
  }
  pieces.push(piece)
  pieces.filter(c => c.len() > 1)
}

/// A curve in data coordinates, clipped to `y-range`.
#let plot-curve(xy, points, y-range, stroke) = {
  import cetz.draw: line
  for piece in clip-y(points, ..y-range) { line(..piece.map(p => xy(..p)), stroke: stroke) }
}

/// Legend: one row per (stroke, label), going down from `origin` (canvas cm).
#let plot-legend(origin, rows, step: 0.5, sample: 0.8, size: 11pt) = {
  import cetz.draw: content, line
  let (x, y) = origin
  for (i, (stroke, label)) in rows.enumerate() {
    line((x, y - i * step), (x + sample, y - i * step), stroke: stroke)
    content((x + sample + 0.15, y - i * step), text(size: size, label), anchor: "west")
  }
}

// Generated by code/typst_data.py from code/cornell.py; do not edit by hand.
// Bare P-wave Cornell tower: m_b = 4.5340 GeV, lattice sigma and gamma, V_0 = 371.5 MeV.
// "@typstyle off" keeps each array as laid out here; typstyle would put one number per line.

// viridis samples used for curve n = 1..7 (as in code/figs.py)
// @typstyle off
#let curve-colours = (rgb("#440154"), rgb("#45347f"), rgb("#345e8d"), rgb("#24848d"), rgb("#22a784"), rgb("#5ec961"), rgb("#bdde26"))

// coupling g [GeV], bare energies E_n^(0) + V_0 [GeV] and f_n(0) [GeV^(-3/2)], n = 1..7
#let cornell-g = 0.057155
// @typstyle off
#let cornell-e-bare = (-0.709572, -0.343112, -0.042810, 0.221692, 0.462778, 0.686930, 0.898048)
// @typstyle off
#let cornell-f0 = (14.4027, 19.5590, 24.8450, 28.2789, 32.1139, 34.8828, 38.0238)

// u_n(r) = r R_(1n)(r) [GeV^(1/2)] at r = 0, 0.02, ..., 3.0 fm
#let un-r-step = 0.02
// @typstyle off
#let un-values = (
  (
    0, 0.0103, 0.0390, 0.0826, 0.1375, 0.2004, 0.2680, 0.3375, 0.4062, 0.4720, 0.5329, 0.5876,
    0.6350, 0.6744, 0.7053, 0.7277, 0.7417, 0.7476, 0.7461, 0.7376, 0.7230, 0.7030, 0.6784, 0.6501,
    0.6188, 0.5854, 0.5504, 0.5145, 0.4784, 0.4425, 0.4072, 0.3729, 0.3399, 0.3084, 0.2787, 0.2507,
    0.2246, 0.2005, 0.1782, 0.1578, 0.1393, 0.1224, 0.1073, 0.0937, 0.0815, 0.0707, 0.0611, 0.0527,
    0.0452, 0.0388, 0.0331, 0.0282, 0.0239, 0.0203, 0.0171, 0.0144, 0.0121, 0.0101, 0.0085, 0.0070,
    0.0059, 0.0049, 0.0040, 0.0033, 0.0027, 0.0022, 0.0018, 0.0015, 0.0012, 0.0010, 0.0008, 0.0007,
    0.0005, 0.0004, 0.0003, 0.0003, 0.0002, 0.0002, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0,
  ),
  (
    0, -0.0118, -0.0442, -0.0928, -0.1524, -0.2183, -0.2857, -0.3501, -0.4078, -0.4556, -0.4910, -0.5124,
    -0.5186, -0.5094, -0.4852, -0.4469, -0.3958, -0.3337, -0.2626, -0.1845, -0.1017, -0.0165, 0.0692, 0.1533,
    0.2341, 0.3102, 0.3801, 0.4430, 0.4981, 0.5450, 0.5833, 0.6132, 0.6347, 0.6483, 0.6544, 0.6536,
    0.6466, 0.6340, 0.6166, 0.5953, 0.5706, 0.5433, 0.5141, 0.4836, 0.4523, 0.4208, 0.3894, 0.3586,
    0.3287, 0.2999, 0.2724, 0.2463, 0.2219, 0.1990, 0.1778, 0.1582, 0.1403, 0.1240, 0.1091, 0.0957,
    0.0837, 0.0730, 0.0634, 0.0549, 0.0474, 0.0408, 0.0350, 0.0299, 0.0255, 0.0217, 0.0184, 0.0156,
    0.0131, 0.0110, 0.0093, 0.0077, 0.0065, 0.0054, 0.0045, 0.0037, 0.0031, 0.0025, 0.0021, 0.0017,
    0.0014, 0.0011, 0.0009, 0.0008, 0.0006, 0.0005, 0.0004, 0.0003, 0.0003, 0.0002, 0.0002, 0.0001,
    0.0001, 0.0001, 0.0001, 0.0001, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0,
  ),
  (
    0, 0.0127, 0.0474, 0.0987, 0.1604, 0.2264, 0.2908, 0.3482, 0.3941, 0.4249, 0.4383, 0.4329,
    0.4088, 0.3669, 0.3091, 0.2380, 0.1567, 0.0689, -0.0217, -0.1115, -0.1969, -0.2748, -0.3424, -0.3975,
    -0.4385, -0.4644, -0.4747, -0.4696, -0.4497, -0.4161, -0.3701, -0.3136, -0.2485, -0.1768, -0.1005, -0.0218,
    0.0575, 0.1355, 0.2105, 0.2813, 0.3466, 0.4055, 0.4573, 0.5016, 0.5381, 0.5668, 0.5878, 0.6014,
    0.6081, 0.6084, 0.6028, 0.5921, 0.5768, 0.5577, 0.5354, 0.5106, 0.4840, 0.4560, 0.4272, 0.3980,
    0.3690, 0.3403, 0.3124, 0.2855, 0.2597, 0.2353, 0.2122, 0.1907, 0.1706, 0.1521, 0.1351, 0.1196,
    0.1054, 0.0926, 0.0811, 0.0708, 0.0616, 0.0534, 0.0462, 0.0398, 0.0342, 0.0293, 0.0250, 0.0213,
    0.0181, 0.0153, 0.0130, 0.0109, 0.0092, 0.0077, 0.0064, 0.0054, 0.0045, 0.0037, 0.0031, 0.0025,
    0.0021, 0.0017, 0.0014, 0.0011, 0.0009, 0.0008, 0.0006, 0.0005, 0.0004, 0.0003, 0.0003, 0.0002,
    0.0002, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0,
  ),
  (
    0, -0.0134, -0.0498, -0.1030, -0.1658, -0.2310, -0.2918, -0.3419, -0.3765, -0.3922, -0.3870, -0.3605,
    -0.3140, -0.2500, -0.1721, -0.0847, 0.0074, 0.0990, 0.1855, 0.2622, 0.3254, 0.3722, 0.4004, 0.4092,
    0.3985, 0.3691, 0.3229, 0.2621, 0.1899, 0.1096, 0.0246, -0.0613, -0.1449, -0.2228, -0.2923, -0.3511,
    -0.3974, -0.4299, -0.4478, -0.4511, -0.4400, -0.4154, -0.3785, -0.3306, -0.2736, -0.2092, -0.1393, -0.0661,
    0.0088, 0.0835, 0.1564, 0.2260, 0.2911, 0.3507, 0.4040, 0.4505, 0.4898, 0.5217, 0.5463, 0.5638,
    0.5744, 0.5786, 0.5770, 0.5700, 0.5584, 0.5427, 0.5236, 0.5017, 0.4776, 0.4519, 0.4252, 0.3977,
    0.3701, 0.3427, 0.3157, 0.2895, 0.2643, 0.2402, 0.2174, 0.1960, 0.1759, 0.1573, 0.1402, 0.1244,
    0.1100, 0.0970, 0.0852, 0.0745, 0.0650, 0.0566, 0.0490, 0.0424, 0.0365, 0.0314, 0.0269, 0.0229,
    0.0195, 0.0166, 0.0140, 0.0119, 0.0100, 0.0084, 0.0070, 0.0059, 0.0049, 0.0041, 0.0034, 0.0028,
    0.0023, 0.0019, 0.0016, 0.0013, 0.0010, 0.0009, 0.0007, 0.0006, 0.0005, 0.0004, 0.0003, 0.0002,
    0.0002, 0.0002, 0.0001, 0.0001, 0.0001, 0.0001, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0,
  ),
  (
    0, 0.0139, 0.0517, 0.1064, 0.1697, 0.2337, 0.2905, 0.3336, 0.3578, 0.3600, 0.3390, 0.2957,
    0.2326, 0.1540, 0.0651, -0.0281, -0.1194, -0.2031, -0.2736, -0.3268, -0.3595, -0.3701, -0.3581, -0.3247,
    -0.2722, -0.2040, -0.1241, -0.0372, 0.0517, 0.1378, 0.2166, 0.2843, 0.3374, 0.3737, 0.3918, 0.3911,
    0.3720, 0.3359, 0.2847, 0.2209, 0.1477, 0.0683, -0.0140, -0.0957, -0.1737, -0.2451, -0.3074, -0.3587,
    -0.3975, -0.4227, -0.4339, -0.4313, -0.4152, -0.3866, -0.3467, -0.2971, -0.2394, -0.1754, -0.1069, -0.0359,
    0.0360, 0.1071, 0.1760, 0.2412, 0.3018, 0.3568, 0.4056, 0.4477, 0.4828, 0.5109, 0.5320, 0.5464,
    0.5544, 0.5564, 0.5530, 0.5448, 0.5322, 0.5160, 0.4967, 0.4749, 0.4513, 0.4262, 0.4003, 0.3739,
    0.3474, 0.3212, 0.2955, 0.2707, 0.2468, 0.2240, 0.2025, 0.1824, 0.1636, 0.1461, 0.1301, 0.1153,
    0.1019, 0.0897, 0.0788, 0.0689, 0.0600, 0.0522, 0.0452, 0.0390, 0.0336, 0.0289, 0.0247, 0.0211,
    0.0179, 0.0152, 0.0129, 0.0109, 0.0092, 0.0077, 0.0064, 0.0054, 0.0045, 0.0037, 0.0031, 0.0026,
    0.0021, 0.0017, 0.0014, 0.0012, 0.0010, 0.0008, 0.0006, 0.0005, 0.0004, 0.0003, 0.0003, 0.0002,
    0.0002, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0,
  ),
  (
    0, -0.0144, -0.0534, -0.1092, -0.1728, -0.2352, -0.2880, -0.3242, -0.3387, -0.3289, -0.2946, -0.2377,
    -0.1626, -0.0749, 0.0185, 0.1106, 0.1942, 0.2632, 0.3126, 0.3389, 0.3404, 0.3175, 0.2719, 0.2073,
    0.1283, 0.0406, -0.0499, -0.1371, -0.2154, -0.2798, -0.3266, -0.3530, -0.3578, -0.3411, -0.3041, -0.2494,
    -0.1805, -0.1013, -0.0166, 0.0691, 0.1511, 0.2252, 0.2878, 0.3359, 0.3674, 0.3812, 0.3769, 0.3552,
    0.3173, 0.2654, 0.2019, 0.1298, 0.0523, -0.0273, -0.1058, -0.1803, -0.2480, -0.3067, -0.3544, -0.3898,
    -0.4121, -0.4210, -0.4164, -0.3991, -0.3698, -0.3299, -0.2807, -0.2240, -0.1615, -0.0949, -0.0260, 0.0435,
    0.1121, 0.1782, 0.2408, 0.2988, 0.3513, 0.3978, 0.4377, 0.4709, 0.4974, 0.5171, 0.5303, 0.5375,
    0.5389, 0.5351, 0.5267, 0.5142, 0.4982, 0.4793, 0.4580, 0.4350, 0.4107, 0.3855, 0.3599, 0.3343,
    0.3090, 0.2843, 0.2603, 0.2373, 0.2154, 0.1947, 0.1753, 0.1571, 0.1404, 0.1249, 0.1108, 0.0979,
    0.0862, 0.0756, 0.0661, 0.0577, 0.0501, 0.0434, 0.0375, 0.0323, 0.0277, 0.0237, 0.0202, 0.0172,
    0.0146, 0.0124, 0.0104, 0.0088, 0.0074, 0.0062, 0.0052, 0.0043, 0.0036, 0.0030, 0.0025, 0.0020,
    0.0017, 0.0014, 0.0011, 0.0009, 0.0007, 0.0006, 0.0005, 0.0004, 0.0003, 0.0003, 0.0002, 0.0002,
    0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0, 0,
  ),
  (
    0, 0.0149, 0.0549, 0.1116, 0.1752, 0.2359, 0.2847, 0.3143, 0.3198, 0.2993, 0.2535, 0.1860,
    0.1023, 0.0097, -0.0837, -0.1699, -0.2415, -0.2926, -0.3190, -0.3187, -0.2921, -0.2417, -0.1716, -0.0879,
    0.0028, 0.0933, 0.1766, 0.2465, 0.2980, 0.3274, 0.3330, 0.3145, 0.2738, 0.2138, 0.1392, 0.0550,
    -0.0329, -0.1186, -0.1966, -0.2620, -0.3109, -0.3406, -0.3495, -0.3374, -0.3053, -0.2555, -0.1912, -0.1160,
    -0.0345, 0.0489, 0.1297, 0.2038, 0.2675, 0.3177, 0.3522, 0.3698, 0.3698, 0.3527, 0.3196, 0.2723,
    0.2131, 0.1448, 0.0706, -0.0066, -0.0834, -0.1571, -0.2249, -0.2844, -0.3338, -0.3716, -0.3968, -0.4089,
    -0.4080, -0.3945, -0.3692, -0.3331, -0.2877, -0.2345, -0.1751, -0.1113, -0.0448, 0.0227, 0.0898, 0.1549,
    0.2169, 0.2747, 0.3274, 0.3744, 0.4151, 0.4494, 0.4771, 0.4982, 0.5130, 0.5217, 0.5248, 0.5226,
    0.5157, 0.5047, 0.4902, 0.4726, 0.4526, 0.4307, 0.4074, 0.3831, 0.3584, 0.3334, 0.3087, 0.2844,
    0.2608, 0.2381, 0.2165, 0.1959, 0.1766, 0.1586, 0.1419, 0.1264, 0.1122, 0.0993, 0.0875, 0.0769,
    0.0674, 0.0588, 0.0511, 0.0444, 0.0383, 0.0331, 0.0284, 0.0243, 0.0208, 0.0177, 0.0151, 0.0128,
    0.0108, 0.0091, 0.0076, 0.0064, 0.0053, 0.0045, 0.0037, 0.0031, 0.0026, 0.0021, 0.0017, 0.0014,
    0.0012, 0.0010, 0.0008, 0.0006, 0.0005, 0.0004, 0.0003,
  ),
)

// f_n(p) [GeV^(-3/2)] at p = 0, 0.02, ..., 2.5 GeV
#let fn-p-step = 0.02
// @typstyle off
#let fn-values = (
  (
    14.403, 14.395, 14.371, 14.331, 14.276, 14.205, 14.119, 14.017, 13.902, 13.771, 13.627, 13.470,
    13.300, 13.117, 12.922, 12.717, 12.500, 12.274, 12.039, 11.795, 11.543, 11.284, 11.018, 10.747,
    10.471, 10.191, 9.907, 9.620, 9.331, 9.040, 8.749, 8.458, 8.167, 7.877, 7.589, 7.303,
    7.020, 6.740, 6.463, 6.191, 5.923, 5.660, 5.402, 5.150, 4.904, 4.663, 4.429, 4.201,
    3.980, 3.766, 3.558, 3.357, 3.163, 2.976, 2.796, 2.623, 2.457, 2.298, 2.145, 1.999,
    1.860, 1.727, 1.600, 1.480, 1.365, 1.257, 1.154, 1.056, 0.965, 0.878, 0.796, 0.719,
    0.647, 0.579, 0.515, 0.456, 0.400, 0.348, 0.300, 0.255, 0.213, 0.175, 0.139, 0.106,
    0.075, 0.047, 0.022, -0.002, -0.023, -0.043, -0.061, -0.077, -0.092, -0.105, -0.116, -0.127,
    -0.136, -0.144, -0.151, -0.158, -0.163, -0.167, -0.171, -0.174, -0.177, -0.179, -0.180, -0.181,
    -0.181, -0.181, -0.181, -0.181, -0.180, -0.179, -0.177, -0.176, -0.174, -0.172, -0.170, -0.167,
    -0.165, -0.163, -0.160, -0.158, -0.155, -0.152,
  ),
  (
    19.559, 19.531, 19.448, 19.310, 19.118, 18.874, 18.577, 18.231, 17.837, 17.398, 16.916, 16.393,
    15.833, 15.239, 14.614, 13.961, 13.284, 12.586, 11.871, 11.143, 10.404, 9.659, 8.911, 8.164,
    7.420, 6.683, 5.956, 5.242, 4.543, 3.862, 3.201, 2.563, 1.948, 1.359, 0.798, 0.265,
    -0.239, -0.712, -1.154, -1.566, -1.946, -2.295, -2.613, -2.900, -3.157, -3.384, -3.582, -3.753,
    -3.897, -4.015, -4.108, -4.178, -4.226, -4.253, -4.261, -4.251, -4.224, -4.182, -4.125, -4.056,
    -3.976, -3.886, -3.787, -3.680, -3.567, -3.448, -3.325, -3.198, -3.069, -2.938, -2.806, -2.673,
    -2.541, -2.410, -2.281, -2.153, -2.028, -1.906, -1.787, -1.671, -1.559, -1.451, -1.346, -1.246,
    -1.150, -1.058, -0.970, -0.886, -0.807, -0.732, -0.660, -0.593, -0.530, -0.471, -0.415, -0.363,
    -0.314, -0.269, -0.226, -0.187, -0.151, -0.117, -0.086, -0.058, -0.032, -0.008, 0.014, 0.033,
    0.051, 0.068, 0.082, 0.095, 0.107, 0.117, 0.126, 0.134, 0.141, 0.147, 0.152, 0.157,
    0.160, 0.163, 0.165, 0.167, 0.168, 0.169,
  ),
  (
    24.845, 24.786, 24.611, 24.320, 23.916, 23.403, 22.787, 22.071, 21.264, 20.372, 19.403, 18.366,
    17.269, 16.123, 14.937, 13.720, 12.483, 11.236, 9.988, 8.748, 7.526, 6.331, 5.170, 4.052,
    2.982, 1.967, 1.013, 0.124, -0.696, -1.445, -2.119, -2.717, -3.239, -3.685, -4.055, -4.352,
    -4.576, -4.732, -4.821, -4.848, -4.816, -4.730, -4.594, -4.413, -4.192, -3.935, -3.649, -3.336,
    -3.003, -2.654, -2.294, -1.926, -1.555, -1.184, -0.817, -0.457, -0.107, 0.230, 0.553, 0.859,
    1.147, 1.415, 1.663, 1.889, 2.094, 2.277, 2.438, 2.578, 2.696, 2.793, 2.871, 2.929,
    2.969, 2.991, 2.998, 2.989, 2.966, 2.931, 2.884, 2.827, 2.761, 2.686, 2.605, 2.518,
    2.426, 2.330, 2.231, 2.130, 2.027, 1.924, 1.821, 1.718, 1.616, 1.516, 1.418, 1.322,
    1.229, 1.139, 1.052, 0.968, 0.887, 0.810, 0.737, 0.667, 0.601, 0.539, 0.480, 0.424,
    0.372, 0.323, 0.278, 0.235, 0.196, 0.159, 0.126, 0.095, 0.066, 0.040, 0.016, -0.006,
    -0.026, -0.044, -0.060, -0.074, -0.087, -0.099,
  ),
  (
    28.279, 28.179, 27.879, 27.385, 26.701, 25.838, 24.807, 23.620, 22.294, 20.844, 19.290, 17.651,
    15.947, 14.197, 12.424, 10.647, 8.885, 7.159, 5.487, 3.884, 2.366, 0.947, -0.362, -1.551,
    -2.613, -3.541, -4.333, -4.987, -5.504, -5.885, -6.135, -6.261, -6.268, -6.166, -5.964, -5.673,
    -5.303, -4.866, -4.373, -3.837, -3.269, -2.681, -2.083, -1.485, -0.898, -0.329, 0.214, 0.722,
    1.192, 1.617, 1.994, 2.321, 2.594, 2.814, 2.981, 3.094, 3.156, 3.169, 3.134, 3.057,
    2.939, 2.786, 2.600, 2.387, 2.151, 1.896, 1.626, 1.345, 1.058, 0.768, 0.478, 0.193,
    -0.086, -0.355, -0.613, -0.856, -1.085, -1.297, -1.491, -1.666, -1.823, -1.960, -2.079, -2.178,
    -2.260, -2.323, -2.369, -2.399, -2.414, -2.414, -2.401, -2.376, -2.340, -2.294, -2.239, -2.176,
    -2.107, -2.033, -1.954, -1.871, -1.785, -1.698, -1.609, -1.520, -1.431, -1.342, -1.255, -1.169,
    -1.085, -1.004, -0.925, -0.849, -0.776, -0.706, -0.639, -0.576, -0.516, -0.459, -0.405, -0.355,
    -0.308, -0.264, -0.223, -0.185, -0.149, -0.117,
  ),
  (
    32.114, 31.962, 31.510, 30.765, 29.740, 28.454, 26.928, 25.188, 23.265, 21.190, 18.999, 16.725,
    14.407, 12.080, 9.779, 7.538, 5.389, 3.360, 1.477, -0.238, -1.768, -3.098, -4.220, -5.127,
    -5.820, -6.302, -6.579, -6.662, -6.565, -6.304, -5.899, -5.368, -4.734, -4.019, -3.245, -2.434,
    -1.607, -0.785, 0.013, 0.772, 1.475, 2.111, 2.670, 3.143, 3.525, 3.812, 4.005, 4.105,
    4.114, 4.038, 3.882, 3.656, 3.367, 3.026, 2.641, 2.223, 1.783, 1.330, 0.874, 0.423,
    -0.013, -0.428, -0.815, -1.168, -1.482, -1.755, -1.984, -2.166, -2.303, -2.393, -2.437, -2.439,
    -2.399, -2.322, -2.209, -2.066, -1.895, -1.701, -1.488, -1.260, -1.022, -0.776, -0.527, -0.278,
    -0.032, 0.207, 0.437, 0.657, 0.864, 1.056, 1.233, 1.393, 1.536, 1.662, 1.770, 1.860,
    1.933, 1.990, 2.030, 2.056, 2.067, 2.065, 2.051, 2.025, 1.990, 1.945, 1.893, 1.834,
    1.769, 1.699, 1.626, 1.549, 1.471, 1.391, 1.311, 1.230, 1.150, 1.072, 0.994, 0.919,
    0.845, 0.774, 0.706, 0.641, 0.578, 0.519,
  ),
  (
    34.883, 34.670, 34.037, 32.997, 31.574, 29.799, 27.711, 25.354, 22.780, 20.043, 17.199, 14.306,
    11.421, 8.599, 5.893, 3.348, 1.008, -1.092, -2.925, -4.470, -5.713, -6.651, -7.286, -7.627,
    -7.691, -7.501, -7.084, -6.471, -5.697, -4.798, -3.810, -2.771, -1.715, -0.677, 0.313, 1.229,
    2.047, 2.749, 3.321, 3.755, 4.044, 4.191, 4.198, 4.074, 3.830, 3.480, 3.041, 2.529,
    1.963, 1.362, 0.745, 0.131, -0.466, -1.028, -1.543, -2.000, -2.389, -2.704, -2.941, -3.097,
    -3.173, -3.171, -3.095, -2.951, -2.746, -2.488, -2.185, -1.848, -1.485, -1.106, -0.721, -0.338,
    0.035, 0.389, 0.720, 1.020, 1.286, 1.513, 1.701, 1.846, 1.948, 2.009, 2.028, 2.009,
    1.953, 1.863, 1.743, 1.596, 1.427, 1.239, 1.037, 0.823, 0.603, 0.380, 0.157, -0.063,
    -0.277, -0.482, -0.676, -0.858, -1.026, -1.179, -1.316, -1.437, -1.541, -1.628, -1.699, -1.754,
    -1.794, -1.819, -1.831, -1.830, -1.817, -1.793, -1.760, -1.718, -1.669, -1.614, -1.553, -1.488,
    -1.419, -1.348, -1.275, -1.201, -1.126, -1.052,
  ),
  (
    38.024, 37.741, 36.900, 35.525, 33.651, 31.330, 28.624, 25.603, 22.347, 18.938, 15.462, 12.002,
    8.641, 5.452, 2.505, -0.143, -2.446, -4.369, -5.890, -7.000, -7.704, -8.017, -7.965, -7.586,
    -6.922, -6.024, -4.945, -3.742, -2.470, -1.184, 0.068, 1.238, 2.288, 3.187, 3.910, 4.441,
    4.772, 4.905, 4.846, 4.608, 4.213, 3.683, 3.047, 2.334, 1.574, 0.798, 0.035, -0.688,
    -1.349, -1.926, -2.404, -2.771, -3.021, -3.150, -3.161, -3.059, -2.854, -2.557, -2.183, -1.747,
    -1.268, -0.762, -0.246, 0.263, 0.749, 1.199, 1.601, 1.945, 2.225, 2.435, 2.572, 2.637,
    2.631, 2.558, 2.423, 2.232, 1.994, 1.717, 1.410, 1.083, 0.744, 0.403, 0.067, -0.255,
    -0.557, -0.832, -1.077, -1.287, -1.460, -1.593, -1.687, -1.741, -1.756, -1.734, -1.679, -1.591,
    -1.476, -1.336, -1.175, -0.998, -0.808, -0.609, -0.406, -0.200, 0.004, 0.203, 0.395, 0.578,
    0.749, 0.907, 1.052, 1.181, 1.295, 1.392, 1.474, 1.540, 1.591, 1.627, 1.650, 1.659,
    1.656, 1.641, 1.617, 1.584, 1.543, 1.495,
  ),
)

#set document(title: "BOχEFT and its application to Xb", author: "Yu Zhang")
#show: deck

#title-slide(
  [BO$chi$EFT and its application to $X_b$],
  [Yu Zhang],
  [Institute of Theoretical Physics, Chinese Academy of Sciences \
    University of Chinese Academy of Sciences],
)

// Overview chain of s_channel_note.tex (Fig. 1), redrawn in cetz.
// Only used by the commented-out overview slide below.
#let overview-diagram() = cetz.canvas(length: 1.18cm, {
  import cetz.draw: *
  let input = rgb(94%, 94%, 100%) // blue!6: lattice and quark input
  let vertex = rgb(100%, 95%, 90%) // orange!10: transition vertex
  let potential = rgb(100%, 92%, 92%) // red!8: s-channel potential
  let scattering = rgb(92%, 100%, 92%) // green!8: hadronic scattering problem
  let tip = (end: "stealth", fill: luma(70), scale: 0.8)
  let link = 0.9pt + luma(70)
  let node(pos, name, fill, body) = content(
    pos,
    align(center, text(size: 13.5pt, body)),
    frame: "rect",
    fill: fill,
    stroke: 0.6pt + luma(60),
    padding: (x: 0.2, y: 0.12),
    name: name,
  )
  let tag(pos, anchor, body) = content(pos, text(size: 12pt, fill: luma(40), body), anchor: anchor, padding: 0.1)

  node((0, 0), "lat", input)[
    Lattice QCD, static $b macron(b)$ + light quarks \
    Bulava _et al._ 2024: $sigma$, $gamma$, $g_l$
  ]
  node((-6.6, -1.65), "corn", input)[
    Cornell $V(r) = V_0 + sigma r + gamma \/ r$ \
    $H = 2 m_b - nabla^2 \/ m_b + V(r)$, $L = 1$
  ]
  node((6.6, -1.65), "gch", input)[
    $g = underbrace(sqrt(2), "flavour") dot underbrace(2, "spin") dot underbrace(1 \/ sqrt(3), S"-wave") dot g_l = 57$ MeV
  ]
  node((-6.6, -3.35), "tower", input)[
    bare tower ${E_n^((0)), R_(1 n)(r)}$ \
    $V_0$ shifts all $E_n$
  ]
  node((-6.6, -5.1), "ff", vertex)[
    Franck–Condon vertex \
    $mel(B macron(B)^* (p), hat(g), n) = g psi_n (p)$ \
    $psi_n (p) = 4 pi integral r^2 dif r thin j_0 (p r) R_(1 n)(r)$
  ]
  node((1.1, -5.1), "V", potential)[
    $V_S^((macron(b) b) + "CT")(p', p; E) = display(sum_(n <= N)) (g^2 f_n (p') f_n (p)) / (E - E_n^((0)) - V_0) + C$
  ]
  node((-6.6, -6.8), "fit", none)[
    fit $V_0$, $C$ to \
    9.893, 10.255, 10.513 GeV
  ]
  node((1.1, -6.8), "lse", scattering)[
    LSE, two-potential solution \
    $det(hat(v)^(-1) + hat(J)) = 0$
  ]
  node((6.6, -6.8), "ome", none)[
    $V^"(OME)"$ ($pi$, $eta$) \
    $3 times 3$ channels
  ]
  node((1.1, -8.4), "out", scattering)[
    4 bound states: $chi_(b 1)(1P)$, $chi_(b 1)(2P)$, $X_b$ (molecular, $cal(P)_(macron(b) b) = 2%$), \
    compact $chi_(b 1)(3P)$ at 10.544 GeV ($cal(P)_(macron(b) b) = 85%$)
  ]

  line("lat.west", ("lat.west", "-|", "corn.north"), "corn.north", mark: tip, stroke: link)
  tag(("lat.west", 50%, ("lat.west", "-|", "corn.north")), "south", [$sigma$, $gamma$])
  line("lat.east", ("lat.east", "-|", "gch.north"), "gch.north", mark: tip, stroke: link)
  tag(("lat.east", 50%, ("lat.east", "-|", "gch.north")), "south", [$g_l$])
  line("corn.south", "tower.north", mark: tip, stroke: link)
  tag(("corn.south", 50%, "tower.north"), "west", [$m_b$, $V_0 = 0$])
  line("tower.south", "ff.north", mark: tip, stroke: link)
  line("ff.east", "V.west", mark: tip, stroke: link)
  line("gch.south", ("gch.south", "|-", "V.east"), "V.east", mark: tip, stroke: link)
  line("V.south", "lse.north", mark: tip, stroke: link)
  line("fit.east", "lse.west", mark: tip, stroke: link)
  line("ome.west", "lse.east", mark: tip, stroke: link)
  line("lse.south", "out.north", mark: tip, stroke: link)
})

// The paper's Fig. 1: the 3P1 bottomonium turns into an S-wave B Bbar* pair through g-hat;
// the heavy quarks are spectators.
#let transition-diagram() = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let head(pos, angle) = {
    let (x, y) = pos
    let (c, s) = (calc.cos(angle), calc.sin(angle))
    line(
      (x + 0.12 * c, y + 0.12 * s),
      (x - 0.12 * c - 0.09 * s, y - 0.12 * s + 0.09 * c),
      (x - 0.12 * c + 0.09 * s, y - 0.12 * s - 0.09 * c),
      close: true,
      fill: black,
      stroke: none,
    )
  }
  let label(pos, anchor, body) = content(pos, text(size: 12pt, body), anchor: anchor, padding: 0.08)
  // heavy quarks go straight through
  line((0.9, 4.26), (7.9, 4.26), stroke: 0.8pt)
  line((0.9, 1.6), (7.9, 1.6), stroke: 0.8pt)
  head((2.6, 4.26), 180deg)
  head((6.2, 4.26), 180deg)
  head((2.66, 1.6), 0deg)
  head((6.24, 1.6), 0deg)
  // light quark pair created inside the box
  line((5.3, 3.8), (7.9, 3.8), stroke: 0.8pt)
  line((5.3, 2.06), (7.9, 2.06), stroke: 0.8pt)
  arc((5.3, 3.8), start: 90deg, stop: 270deg, radius: (0.86, 0.87), stroke: 0.8pt)
  head((6.6, 3.8), 0deg)
  head((6.6, 2.06), 180deg)
  head((4.44, 2.93), 90deg)
  rect((3.0, 1.04), (5.84, 4.8), stroke: 0.6pt + red)
  label((4.42, 1.0), "north", text(fill: red)[$hat(g)$])
  label((0.85, 4.26), "east", [$macron(b)$])
  label((0.85, 1.6), "east", [$b$])
  label((7.95, 4.3), "west", [$macron(b)$])
  label((7.95, 3.78), "west", [$q$])
  label((7.95, 2.1), "west", [$macron(q)$])
  label((7.95, 1.56), "west", [$b$])
  label((2.05, 2.93), "center", [$pw(3, P, 1) thin [b macron(b)]$])
  label((6.95, 2.93), "center", [$pw(3, S, 1) thin [B macron(B)^*]$])
})

// Stroke of curve n (0-based) in the tower plots: n < 4 solid, n >= 4 dashed (as code/figs.py).
#let tower-stroke(n) = if n < 4 { 1.4pt + curve-colours.at(n) } else {
  (paint: curve-colours.at(n), dash: "dashed", thickness: 0.8pt)
}

// u_n(r) of the bare Cornell tower (data: data.typ). Only used by a commented-out slide.
#let un-plot() = line-plot(
  size: (9.4, 4.9),
  x-range: (0, 3),
  y-range: (-0.6, 0.8),
  x-ticks: (0, 0.5, 1, 1.5, 2, 2.5, 3),
  x-digits: 1,
  y-ticks: (-0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8),
  y-digits: 1,
  x-label: [$r$ [fm]],
  y-label: [$u_n (r)$ [$"GeV"^(1\/2)$]],
  y-label-gap: 1.25,
  tick-size: 10pt,
  label-size: 12pt,
  xy => {
    import cetz.draw: *
    line(xy(0, 0), xy(3, 0), stroke: 0.5pt)
    line(xy(1.21, -0.6), xy(1.21, 0.8), stroke: (paint: gray, dash: "dotted", thickness: 0.8pt))
    content(xy(1.24, 0.78), text(size: 9pt, fill: gray)[$V(r) = hat(E)_1$ \ ($r approx 1.2$ fm)], anchor: "north-west")
    for (n, u) in un-values.enumerate() {
      line(..u.enumerate().map(((i, v)) => xy(i * un-r-step, v)), stroke: tower-stroke(n))
    }
    plot-legend(
      xy(1.8, -0.2),
      range(4).map(n => (tower-stroke(n), [$n = #(n + 1)$])),
      step: 0.36,
      sample: 0.6,
      size: 9pt,
    )
    plot-legend(
      xy(2.42, -0.2),
      range(4, 7).map(n => (tower-stroke(n), [$n = #(n + 1)$])),
      step: 0.36,
      sample: 0.6,
      size: 9pt,
    )
  },
)

// f_n(p) of the bare Cornell tower (data: data.typ). Only used by a commented-out slide.
#let fn-plot() = line-plot(
  size: (9.4, 4.9),
  x-range: (0, 2.5),
  y-range: (-10, 40),
  x-ticks: (0, 0.5, 1, 1.5, 2, 2.5),
  x-digits: 1,
  y-ticks: (-10, 0, 10, 20, 30, 40),
  x-label: [$p$ [GeV]],
  y-label: [$f_n (p)$ [$"GeV"^(-3\/2)$]],
  y-label-gap: 1.1,
  tick-size: 10pt,
  label-size: 12pt,
  xy => {
    import cetz.draw: *
    line(xy(0, 0), xy(2.5, 0), stroke: 0.5pt)
    line(xy(0.695, -10), xy(0.695, 40), stroke: (paint: gray, dash: "dotted", thickness: 0.8pt))
    content(
      xy(0.72, 37),
      text(size: 9pt, fill: gray)[$kappa approx 0.695$ GeV \ ($E_B = 91$ MeV)],
      anchor: "north-west",
    )
    for (n, f) in fn-values.enumerate() {
      line(..f.enumerate().map(((i, v)) => xy(i * fn-p-step, v)), stroke: tower-stroke(n))
    }
    plot-legend(
      xy(1.5, 37),
      range(4).map(n => (tower-stroke(n), [$f_#(n + 1) (p)$])),
      step: 0.36,
      sample: 0.6,
      size: 9pt,
    )
    plot-legend(
      xy(2.0, 37),
      range(4, 7).map(n => (tower-stroke(n), [$f_#(n + 1) (p)$])),
      step: 0.36,
      sample: 0.6,
      size: 9pt,
    )
  },
)

// V_S(0, 0; E) for N = 4, computed from E_n and f_n(0) (data.typ). Only used by a commented-out slide.
#let v-of-e-plot() = {
  let es = range(1201).map(i => -0.85 + i * 0.001) // GeV
  let term(n, e) = cornell-g * cornell-g * calc.pow(cornell-f0.at(n), 2) / (e - cornell-e-bare.at(n))
  let y-range = (-60, 60)
  let (w, h) = (10.2, 6.4)
  line-plot(
    size: (w, h),
    x-range: (-910, 410),
    y-range: y-range,
    x-ticks: (-800, -600, -400, -200, 0, 200, 400),
    y-ticks: (-60, -40, -20, 0, 20, 40, 60),
    x-label: [$E = M - M_"th"$ [MeV]],
    y-label: [$V_S^((macron(b) b))(0, 0; E)$ [$"GeV"^(-2)$]],
    y-label-gap: 1.2,
    tick-size: 11pt,
    label-size: 13pt,
    xy => {
      import cetz.draw: *
      line(xy(-910, 0), xy(410, 0), stroke: 0.5pt)
      for n in range(4) {
        let colour = curve-colours.at(n)
        let e-n = 1000 * cornell-e-bare.at(n)
        line(xy(e-n, -60), xy(e-n, 60), stroke: (paint: colour, dash: "dotted", thickness: 0.6pt))
        plot-curve(xy, es.map(e => (1000 * e, term(n, e))), y-range, (paint: colour, dash: "dashed", thickness: 0.9pt))
      }
      plot-curve(xy, es.map(e => (1000 * e, range(4).map(n => term(n, e)).sum())), y-range, 1.6pt)
      line(xy(0, -60), xy(0, 60), stroke: 0.8pt + red)
      content(xy(8, -55), text(size: 10pt, fill: red)[$B macron(B)^*$ thr.], anchor: "west")
      plot-legend(
        (w + 0.3, h - 0.2),
        range(4).map(n => ((paint: curve-colours.at(n), dash: "dashed", thickness: 0.9pt), [$n = #(n + 1)$ term]))
          + ((1.6pt, [sum, $N = 4$]),),
        step: 0.55,
        size: 11pt,
      )
    },
  )
}

// ---------------------------------------------------------------------------
#slide[BOχEFT approach to ordinary and exotic hadrons][
  Main sources of information on hadronic states:
  - #text(fill: blue)[Lattice QCD] $->$ First principle calculations of static interquark potentials, including string breaking effects $->$ input for #text(fill: rgb("#FF6600"))[short-range physics]
  - #text(fill: blue)[High-energy experiment] $->$ Line shapes and branching fractions in terms of hadronic states $->$ input for #text(fill: rgb("#FF6600"))[long-range physics]

  #text(fill: red)[*Problem: How to incorporate both sources of information in a single approach?*]

  #text(fill: blue)[BOEFT] (Braaten, Brambilla, et al.): Coupled Schrödinger equations in coordinate space
  - #text(fill: rgb("#FF6600"))[Pro:] Direct correspondence to lattice potentials $->$ short-range physics naturally captured
  - #text(fill: rgb("#FF6600"))[Con:] Missing connection to hadronic degrees of freedom $->$ long-range physics parametrised

  #text(fill: blue)[BOχEFT]: Coupled Lippmann-Schwinger equations in momentum space:
  - #text(fill: rgb("#FF6600"))[Pro:] Long-range physics naturally captured, including multibody effects and exchanges
  - #text(fill: rgb("#FF6600"))[Con:] Connection to short-range physics is nontrivial (comes as chiral expansion in $p^2/Lambda^2$)
  #text(fill: red)[*Hope: Merge both approaches to unified systematically improvable method*]

]




// The three symmetries of two static sources, redrawn from the speech's TikZ figure.
#let bo-figure() = cetz.canvas(length: 1.4cm, {
  import cetz.draw: *
  let tip = (end: "stealth", fill: black, scale: 0.9)
  let axis-stroke = (paint: gray, dash: "dashed", thickness: 0.7pt)
  let src(pos, quark) = circle(pos, radius: 0.12, fill: if quark { black } else { white }, stroke: 1.1pt)
  let lbl(pos, anchor, body) = content(pos, text(size: 17pt, body), anchor: anchor, padding: 0.08)
  let note(pos, body) = content(pos, align(center, text(size: 15pt, body)), anchor: "north")

  // (a) rotations about the axis
  circle((0, 0), radius: (1.9, 0.7), fill: luma(235), stroke: none)
  line((-2.3, 0), (2.5, 0), stroke: axis-stroke, mark: (end: "stealth", fill: gray, scale: 0.9))
  lbl((2.5, 0), "west", [$hat(bold(r)) = hat(z)$])
  src((-1.1, 0), false)
  lbl((-1.1, -0.15), "north", [$macron(b)$])
  src((1.1, 0), true)
  lbl((1.1, -0.15), "north", [$b$])
  arc((2.05, 0.55), start: 90deg, stop: -200deg, radius: (0.18, 0.55), stroke: 1.1pt, mark: tip)
  lbl((2.05, 0.6), "south", [$R_(hat(z))(phi)$])
  note((
    0,
    -1.15,
  ))[*(a)* rotations about the axis \ conserve $lambda_l = arrow(j)_l dot hat(bold(r))$ \ $Lambda = |lambda_l|$: $Sigma, Pi, Delta, dots$]

  // (b) CP: P swaps the positions, C swaps b and bbar back
  let row(y, left-quark) = {
    line((4.7, y), (6.7, y), stroke: 0.7pt + gray)
    src((4.7, y), left-quark)
    src((6.7, y), not left-quark)
    lbl((4.55, y), "east", if left-quark [$b$] else [$macron(b)$])
    lbl((6.85, y), "west", if left-quark [$macron(b)$] else [$b$])
  }
  row(0.8, false)
  row(0, true)
  row(-0.8, false)
  line((5.7, 0.65), (5.7, 0.15), stroke: 1.1pt, mark: tip)
  lbl((5.8, 0.4), "west", text(size: 14pt)[$P$: $arrow(r) arrow.r -arrow(r)$])
  line((5.7, -0.15), (5.7, -0.65), stroke: 1.1pt, mark: tip)
  lbl((5.8, -0.4), "west", text(size: 14pt)[$C$: $b arrow.l.r macron(b)$])
  note((
    5.7,
    -1.15,
  ))[*(b)* $C P$ maps the configuration \ onto itself: eigenvalue \ $eta = g space (+1)$ or $u space (-1)$]

  // (c) reflection through a plane containing the axis
  line((9.1, -0.35), (12.7, -0.35), (13.1, 0.35), (9.5, 0.35), close: true, fill: luma(245), stroke: 0.6pt + gray)
  lbl((9.48, -0.2), "center", text(size: 13pt, fill: gray)[$x z$])
  line((9.0, 0), (13.2, 0), stroke: axis-stroke)
  src((10.0, 0), false)
  src((12.2, 0), true)
  circle((11.3, 0.9), radius: 0.05, fill: black, stroke: none)
  lbl((11.4, 0.9), "west", text(size: 14pt)[$(x, y, z)$])
  circle((11.3, -0.9), radius: 0.05, fill: gray, stroke: none)
  lbl((11.4, -0.9), "west", text(size: 14pt)[$(x, -y, z)$])
  line(
    (11.3, 0.78),
    (11.3, -0.78),
    stroke: (dash: "dotted", thickness: 0.8pt),
    mark: (
      start: "stealth",
      end: "stealth",
      fill: black,
      scale: 0.7,
    ),
  )
  line((9.2, 0.75), (9.7, 0.75), stroke: 0.8pt, mark: (end: "stealth", fill: black, scale: 0.6))
  lbl((9.7, 0.75), "west", text(size: 14pt)[$z$])
  line((9.2, 0.75), (9.2, 1.2), stroke: 0.8pt, mark: (end: "stealth", fill: black, scale: 0.6))
  lbl((9.2, 1.2), "south", text(size: 14pt)[$y$])
  line((9.2, 0.75), (9.0, 0.4), stroke: 0.8pt, mark: (end: "stealth", fill: black, scale: 0.6))
  lbl((9.0, 0.4), "east", text(size: 14pt)[$x$])
  note((
    11.1,
    -1.15,
  ))[*(c)* $M_(x z) = P R_y (pi)$: $y arrow.r -y$, \ sources stay put, $lambda_l arrow.r -lambda_l$ \ $arrow.r.double$ $sigma = plus.minus$ only for $Lambda = 0$]
})

// Schematic BO static energies, after Berwein, Brambilla, Tarrús Castellà, Vairo, PRD 92, 114019 (2015).
// Only used by the commented-out slide below.
#let bo-energies-sketch() = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let at(x, y) = ((x - 130) * 0.0095, (940 - y) * 0.0095) // traced on a 1494 x 1018 grid
  let green = rgb("#5aab3a")
  let curve(..pts) = catmull(..pts.pos().map(p => at(..p)), tension: 0.5, stroke: 1.2pt)
  let level(x0, x1, y) = line(at(x0, y), at(x1, y), stroke: (dash: "dashed", thickness: 0.9pt))
  let gap(x, y0, y1, scale) = line(at(x, y0), at(x, y1), stroke: 1.4pt + green, mark: (
    start: "stealth",
    end: "stealth",
    fill: green,
    scale: scale,
  ))
  line(at(130, 940), at(130, 8), stroke: 1.1pt, mark: (end: "stealth", fill: black))
  line(at(130, 940), at(1490, 940), stroke: 1.1pt, mark: (end: "stealth", fill: black))
  curve(
    (245, 880),
    (262, 830),
    (282, 790),
    (305, 752),
    (340, 722),
    (400, 690),
    (500, 648),
    (600, 606),
    (700, 570),
    (800, 535),
    (900, 500),
    (1000, 465),
    (1100, 430),
    (1200, 395),
    (1300, 360),
    (1405, 325),
  )
  curve(
    (208, 140),
    (210, 300),
    (215, 380),
    (225, 425),
    (245, 448),
    (280, 457),
    (350, 462),
    (450, 462),
    (550, 455),
    (650, 445),
    (750, 432),
    (850, 412),
    (950, 385),
    (1050, 360),
    (1150, 335),
    (1250, 310),
    (1405, 258),
  )
  curve(
    (285, 456),
    (350, 452),
    (450, 438),
    (550, 416),
    (650, 390),
    (750, 362),
    (850, 333),
    (950, 300),
    (1050, 262),
    (1150, 230),
    (1250, 200),
    (1405, 152),
  )
  level(220, 945, 383)
  level(218, 830, 417)
  level(245, 590, 443)
  level(130, 300, 762)
  level(130, 281, 793)
  level(130, 266, 823)
  level(130, 254, 853)
  gap(380, 468, 696, 0.8)
  gap(290, 818, 872, 0.45)
  content(at(398, 575), text(size: 14pt)[$Delta tilde Lambda_"QCD"$], anchor: "west")
  content(at(315, 845), text(size: 13pt)[$E tilde m_Q v^2$], anchor: "west")
  content(at(1222, 140), text(size: 16pt)[$Sigma_u^-$])
  content(at(1222, 262), text(size: 16pt)[$Pi_u$])
  content(at(1225, 462), text(size: 16pt)[$Sigma_g^+$])
  content(at(55, 475), text(size: 15pt)[$E^((0))_(Lambda_eta^sigma)(r)$], angle: 90deg)
  content(at(1405, 985), text(size: 15pt)[$r$])
})

// ---------------------------------------------------------------------------
#slide[BO symmetry: rotations around the axis between two sources][
  - angular momentum comes from the SO(3) rotational symmetry of our theory
  - static $b$ and $macron(b)$ fix an axis: only rotations about it remain, SO(3) $arrow.r$ cylindrical symmetry
  - conserved: $lambda_l = arrow(j)_l dot hat(bold(r))$, with $arrow(j)_l$ the total angular momentum of the light d.o.f.; #h(0.2em) $Lambda = |lambda_l|$, written $Sigma, Pi, Delta, dots$ for $Lambda = 0, 1, 2, dots$
  #v(0.5em)
  #align(center, bo-figure())
  #caption[Two static sources at $plus.minus arrow(r) \/ 2$ on the $z$ axis; filled: $b$, open: $macron(b)$, shaded: light degrees of freedom]
]

#slide[BO symmetry: $C P$ and reflections][
  - $eta = C P$: $P$ swaps the positions of $b$ and $macron(b)$, $C$ exchanges quark and antiquark, so the configuration is restored (panel b); #h(0.2em) $eta = g$ $(+1)$ or $u$ $(-1)$
  - $sigma = plus.minus$: reflection through a plane containing the axis; take $arrow(r)$ along $z$ and the $x z$ plane (panel c):
  $
    M_(x z) = P R_y (pi): quad (x, y, z) stretch(arrow.r, size: #3em)^(R_y (pi)) (-x, y, -z) stretch(arrow.r, size: #3em)^P (x, -y, z)
  $
  - the sources stay put; on a light state
  $
    P R_y (pi) ket(j_l\, lambda_l) = P (-1)^(j_l - lambda_l) ket(j_l\, -lambda_l) quad arrow.r.double quad sigma ket(j_l\, 0) = P (-1)^(j_l) ket(j_l\, 0)
  $
  - for $lambda_l != 0$ the reflection maps $lambda_l arrow.r -lambda_l$: a degenerate pair, so $sigma$ is quoted only for $Lambda = 0$
]

// Eigenvalues (solid) and diagonal "diabatic" entries (dashed) of the lattice model H(r),
// Bulava et al. 2024 Eq. (6), computed from the parameters in the table (as code/figs.py).
#let lattice-levels-plot() = {
  let hbarc = 0.1973269804 // GeV fm
  let sqrt-t0 = 0.1443 // fm
  let gev(a) = a / sqrt-t0 * hbarc // lattice units -> GeV
  let (v0, e1, e2, gl, gs) = (-0.835, 0.0034, 0.1005, 0.0256, 0.0134).map(gev)
  let sigma = 0.1061 / (sqrt-t0 * sqrt-t0) * hbarc * hbarc // GeV^2
  let gamma = -0.434
  let v-string(r) = v0 + sigma * r / hbarc + gamma * hbarc / r // V(r) [GeV], r [fm]
  // eigenvalues of a real symmetric 3 x 3 matrix, ascending (trigonometric closed form)
  let eigenvalues(a11, a22, a33, a12, a13, a23) = {
    let q = (a11 + a22 + a33) / 3
    let off = a12 * a12 + a13 * a13 + a23 * a23
    let p = calc.sqrt((calc.pow(a11 - q, 2) + calc.pow(a22 - q, 2) + calc.pow(a33 - q, 2) + 2 * off) / 6)
    let (b11, b22, b33, b12, b13, b23) = (a11 - q, a22 - q, a33 - q, a12, a13, a23).map(v => v / p)
    let det = b11 * (b22 * b33 - b23 * b23) - b12 * (b12 * b33 - b23 * b13) + b13 * (b12 * b23 - b22 * b13)
    let phi = calc.acos(calc.max(-1, calc.min(1, det / 2))) / 3
    let hi = q + 2 * p * calc.cos(phi)
    let lo = q + 2 * p * calc.cos(phi + 120deg)
    (lo, 3 * q - hi - lo, hi)
  }
  let rs = range(351).map(i => 0.25 + i * 0.005)
  let levels = rs.map(r => eigenvalues(v-string(r), e1, e2, calc.sqrt(2) * gl, gs, 0))
  let (blue, green, red) = (rgb("#1f77b4"), rgb("#2ca02c"), rgb("#d62728")) // matplotlib tab: colours
  let y-range = (-500, 400)
  line-plot(
    size: (14.2, 7.4),
    x-range: (0.25, 2.0),
    y-range: y-range,
    x-ticks: (0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0),
    x-digits: 1,
    y-ticks: (-400, -200, 0, 200, 400),
    x-label: [$r$ [fm]],
    y-label: [$E - 2 E_(macron(Q) l)$ [MeV]],
    y-label-gap: 1.5,
    xy => {
      import cetz.draw: *
      let dashed(paint) = (paint: paint, dash: "dashed", thickness: 0.9pt)
      plot-curve(xy, rs.map(r => (r, 1000 * v-string(r))), y-range, dashed(gray))
      line(xy(0.25, 1000 * e1), xy(2.0, 1000 * e1), stroke: dashed(blue))
      line(xy(0.25, 1000 * e2), xy(2.0, 1000 * e2), stroke: dashed(green))
      for k in range(3) {
        plot-curve(xy, rs.zip(levels).map(((r, l)) => (r, 1000 * l.at(k))), y-range, 1.5pt)
      }
      line(xy(1.211, -500), xy(1.211, 400), stroke: (paint: red, dash: "dotted", thickness: 0.8pt))
      content(xy(1.17, 330), text(size: 11pt, fill: red)[$r_l^star = 1.21$ fm], anchor: "east")
      plot-legend(xy(1.08, -250), (
        (dashed(gray), [$hat(V)(r)$ (string, diabatic)]),
        (dashed(blue), [$hat(E)_1$ ($B macron(B)$, diabatic)]),
        (dashed(green), [$hat(E)_2$ ($B_s macron(B)_s$, diabatic)]),
        (1.5pt, [eigenvalues (adiabatic levels)]),
      ))
    },
  )
}

#slide[BO levels and string breaking][
  Light states of $ket(B macron(B))$ and of the string, labelled with the BO rules: #h(0.3em) $eta = C P$ of the light degrees of freedom; $sigma = P (-1)^(j_l)$ for $lambda_l = 0$.
  #v(0.3em)
  #align(center, text(size: 16pt, table(
    columns: 7,
    align: (left, center, center, center, center, center, left),
    toprule, [light configuration], [$j_l^(P C)$], [$lambda_l$], [$eta$], [$sigma$], [label],
    [role], midrule, [vacuum (string)], [$0^(+ +)$], [0], [$g$], [$+$],
    [$Sigma_g^+$],
    [compact $macron(b) b$, Cornell potential],
    [$S$-wave pair, light triplet],
    [$1^(- -)$],
    [0],
    [$g$],
    [$+$],

    [$Sigma_g^(+')$],
    [mixes with the string],
    [$S$-wave pair, light triplet],
    [$1^(- -)$],
    [$plus.minus 1$],
    [$g$],
    [–],

    [$Pi_g$], [no direct mixing], [$S$-wave pair, light singlet], [$0^(- +)$], [0], [$u$], [$-$],
    [$Sigma_u^-$], [no direct mixing; cannot give $1^(+ +)$], bottomrule,
  )))
  #v(0.3em)
  - in $ket(B macron(B))$: $ket(1_l\, 0) in Sigma_g^(+')$, #h(0.2em) $ket(1_l\, plus.minus 1) in Pi_g$, #h(0.2em) $ket(0_l\, 0) in Sigma_u^-$; the labels are conserved for static quarks, so only the $ket(1_l\, 0)$ piece mixes with the string
  - $Sigma_g^+$ and $Sigma_g^(+')$ share all labels, so their levels cannot cross $arrow.r$ avoided crossing = string breaking
]




#slide(
  refs: [Bulava _et al._ 2024, Eqs. (6) & (11) and Table 4],
)[What lattice measures: static potential with string breaking][
  #grid(
    columns: (1.45fr, 1fr),
    column-gutter: 1em,
    align: horizon,
    lattice-levels-plot(),
    [
      $
        H(r) = mat(V(r), sqrt(2) g_l, g_s; sqrt(2) g_l, hat(E)_1, 0; g_s, 0, hat(E)_2) \ V(r) = hat(V)_0 + sigma r + gamma / r
      $
    ],
  )
  #align(center, text(size: 16pt, table(
    columns: 8,
    align: (left,) + (center,) * 7,
    toprule, [], [$hat(E)_1$], [$hat(E)_2$], [$g_l$], [$g_s$], [$sigma$], [$hat(V)_0$],
    [$gamma$], midrule, [units of $t_0$], [0.0034(3)], [0.1005(7)], [0.0256(3)], [0.0134(4)], [0.1061(7)],
    [$-0.835(7)$], [$-0.434(11)$], [physical], [5 MeV], [137 MeV], [*35 MeV*], [18 MeV], [*0.198 GeV#super[2]*],
    [$-1.14$ GeV], [$bold(-0.434)$], bottomrule,
  )))
  - $sqrt(t_0) = 0.1443(7)(13)$ fm
]


#slide[Proof-of-concept BO$chi$EFT calculation at LO][
  Consider scattering problem for $B macron(B)^*$ system with $J^(italic(P) italic(C)) =1^(++)$ via potential
  $ V = V^"(OME)" + sum_(n = 1)^N V_n^((macron(b) b)) + C(Lambda, N) $
  - #text(fill: blue)[_u_-channel meson exchanges] $->$ potential #text(fill: red)[$V^"(OME)"$]:\ No free parameters
  #v(1em)
  - #text(fill: blue)[_s_-channel exchange of bottomonium states] $->$ potential #text(fill: red)[$V^((macron(b) b))$]:\ Parameters of interquark interaction and strength of transition $macron(b)b ->B macron(B)^*$ can be extracted from lattice-QCD calculations
  #v(1em)
  - #text(fill: blue)[Short-range counterterm] $->$  #text(fill: red)[$C$]:\ Absorbs all neglected effects
  #v(1em)
  Remaining free parameters can be fixed to the experimental spectrum of $chi_(b 1)$ bottomonia

]

#slide[Quantum numbers of $1^(+ +)$ pair][
  $
    arrow(J) = arrow(s)_H + arrow(j)_l + arrow(L), quad J^(P C) = 1^(+ +), quad P = (-1)^L, quad C = (-1)^(s_H + j_l + L)
  $
  - $P = +$ makes $L$ even
  - then $C = +$ makes $s_H + j_l$ even: $(s_H, j_l) = (0, 0)$ or $(1, 1)$
  - with $(0, 0)$ we would get $J = L$, which is even and never 1 #h(0.3em) $arrow.r.double$ #h(0.3em) $s_H = j_l = 1$
  $ s_H times.o j_l = 1 times.o 1 = 0 plus.o 1 plus.o 2 $
  combined with $L = 0, 2$ to $J = 1$, this gives the $1^(+ +)$ meson pairs
  $ B macron(B)^* (pw(3, S, 1)), quad B macron(B)^* (pw(3, D, 1)), quad B^* macron(B)^* (pw(5, D, 1)) $
]

/* Overview diagram, commented out.
#slide[Where $V^((macron(b) b))$ sits][
  #align(center, overview-diagram())
  #caption[Blue: input; orange: vertex; red: $s$-channel potential + contact term; green: scattering problem.]
]
*/

// #slide(
//   refs: [radii, $p thin r_"rms"$ and plots: our estimate from the bare Cornell tower, $m_b = 4.534$ GeV],
// )[The suppression is parametric][
//   - $p tilde Q approx kappa_(X_b) = 0.695$ GeV; rms radii of the bare states $n = 1$–$4$: $0.41$, $0.66$, $0.87$, $1.05$ fm
//   - $p thin r_"rms" approx 1.4, 2.3, 3.1, 3.7$: not small
//   - so the $S$-wave restriction is a counting statement, not a numerical one
//   #grid(
//     columns: (1fr, 1fr),
//     column-gutter: 1em,
//     align: center,
//     [#un-plot() #caption[$u_n (r) = r R_(1 n)(r)$; dotted: string–$B macron(B)$ crossing]],
//     [#fn-plot() #caption[$f_n (p) = sqrt(4 pi) integral r^2 dif r thin j_0 (p r) R_(1 n)(r)$; dotted: $kappa$]],
//   )
// ]

#slide[Why exactly three channels][
  $P = P_1 P_2 (-1)^L = (-1)^L$; #h(0.3em) $C = (-1)^(L + S)$ for $B macron(B)$ and $B^* macron(B)^*$; #h(0.3em) $B macron(B)^*$: $C = plus.minus (-1)^L$ for $(ket(B macron(B)^*) minus.plus ket(B^* macron(B))) \/ sqrt(2)$
  #v(0.2em)
  #align(center, text(size: 15.5pt, table(
    columns: 5,
    align: (left, center, center, left, left),
    inset: (x: 0.5em, y: 0.22em),
    toprule, [pair], [$S$], [$L$], [allowed $J^(P C)$],
    [$1^(+ +)$?], midrule, [$B macron(B)$], [0], [$L$],
    [$J = L$: $0^(+ +), 1^(- -), 2^(+ +), dots$], [no], [$B macron(B)^*$, $C$-even], [1], [0],
    [$1^(+ +)$], [*yes:* $pw(3, S, 1)$], [$B macron(B)^*$, $C$-even], [1], [2],
    [$1^(+ +), 2^(+ +), 3^(+ +)$], [*yes:* $pw(3, D, 1)$], [$B macron(B)^*$, $C$-odd], [1], [0, 2],
    [$1^(+ -), dots$], [no], [$B^* macron(B)^*$], [0], [0],
    [$0^(+ +)$], [no], [$B^* macron(B)^*$], [1], [0],
    [$1^(+ -)$], [no], [$B^* macron(B)^*$], [2], [0],
    [$2^(+ +)$], [no], [$B^* macron(B)^*$], [0], [2],
    [$2^(+ +)$], [no], [$B^* macron(B)^*$], [1], [2],
    [$1^(+ -), 2^(+ -), 3^(+ -)$], [no], [$B^* macron(B)^*$], [2], [2],
    [$0^(+ +), dots, 4^(+ +)$], [*yes:* $pw(5, D, 1)$], [any], [$<= 2$], [$>= 4$],
    [$J >= L - S >= 2$], [no], bottomrule,
  )))
]

#slide[The coupled-channel Hamiltonian and the vector of state][
  $
    cal(H) = mat(
      H - M_"th", 0, dots.c, hat(g)^dagger;
      0, H - M_"th", dots.c, hat(g)^dagger;
      dots.v, dots.v, dots.down, dots.v;
      hat(g), hat(g), dots.c, H_(M M)
    ) quad "acting on" quad ket(Psi) = mat(lambda_1 ket([macron(b) b]_1 (1P)); lambda_2 ket([macron(b) b]_1 (2P)); dots.v; phi(q) ket(B macron(B)^*))
  $
  #grid(
    columns: (1fr, auto),
    column-gutter: 1.5em,
    align: horizon,
    [
      $ "normalisation:" quad sum_n |lambda_n|^2 + integral (q^2 dif q) / (2 pi^2) |phi(q)|^2 = 1 $
      - $phi(q) = braket(q, Psi)$; $ket(q)$ are the meson-pair states, normalised as $braket(q', q) = (2 pi^2) / q^2 delta(q' - q)$
    ],
    [
      #transition-diagram()
      #caption[$pw(3, P, 1)$ bottomonium $arrow.r$ $S$-wave $B macron(B)^*$ via $hat(g)$; \ the heavy quarks are spectators]
    ],
  )
  Note: At LO $[macron(b) b]_1 (n P)$ bottomonia couple only to $B macron(B)^*(pw(3, S, 1))$ (here simply $B macron(B)^*$); \ coupling to $B macron(B)^*(pw(3, D, 1))$ and $B^* macron(B)^*(pw(5, D, 1))$ appears at higher orders
]

#slide[What to do next?][

  - Task 1: Derive $V^((macron(b) b))$ from
    $cal(H)$ and define probabilities for different components of $ket(Psi)$
    $
      hat(V)(E) = sum_(n <= N) (hat(g) ket(n) bra(n) hat(g)^dagger) / (E - E_n) + C(N)
    $
  - Task 2: Establish relation between BO$chi$EFT channels and BOEFT levels
  $
    mat(ket(Sigma_g^(+')); ket(Pi_g\; 1); ket(Pi_g\; 2)) = underbrace(mat(1 / sqrt(3), 1 / sqrt(6), -1 / sqrt(2); sqrt(2 / 3), -1 / (2 sqrt(3)), 1 / 2; 0, sqrt(3) / 2, 1 / 2), U) mat(ket(B macron(B)^* (pw(3, S, 1))); ket(B macron(B)^* (pw(3, D, 1))); ket(B^* macron(B)^* (pw(5, D, 1)))) quad quad U U^T = bold(1)
  $
  - Task 3: Relate transition matrix element of $hat(g)$ with the lattice string breaking coupling $g_l$
  $
    |g| = 2 / sqrt(3) sqrt(2) thin g_l = 57 "MeV" quad (g_l = 35 "MeV")
  $


]

#slide[Task 1, Step 1: Projectors and the block form of $cal(H)$][
  Split the space into the compact sector $Q$ and the meson-pair sector $M$:
  $
    P_Q = sum_n ket(n) bra(n), quad P_M = integral_0^infinity (q^2 dif q) / (2 pi^2) ket(q) bra(q), quad P_Q + P_M = bold(1), quad P_Q P_M = 0
  $
  Sandwich $cal(H)$ between $bold(1) = P_Q + P_M$ on both sides:
  $
    cal(H) = (P_Q + P_M) cal(H) (P_Q + P_M) = underbrace(P_Q cal(H) P_Q, H_(Q Q)) + underbrace(P_M cal(H) P_M, H_(M M)) + underbrace(P_M cal(H) P_Q, hat(g)) + underbrace(P_Q cal(H) P_M, hat(g)^dagger)
  $
  - $H_(Q Q) = P_Q (H - M_"th") P_Q = sum_n E_n ket(n) bra(n)$
  - $P_Q cal(H) P_M = (P_M cal(H) P_Q)^dagger = hat(g)^dagger$, because $cal(H)$ is Hermitian
  - ordered as (compact, meson pair): $cal(H) = mat(H_(Q Q), hat(g)^dagger; hat(g), H_(M M))$, i.e. the Hamiltonian matrix from before with all bottomonium rows in one block
]

#slide[Task 1, Step 2: Projecting the Schrödinger equation][
  Write $cal(H) ket(Psi) = E ket(Psi)$ as $cal(H) (P_Q + P_M) ket(Psi) = E ket(Psi)$ and multiply from the left by $P_Q$:
  $ P_Q cal(H) P_Q ket(Psi) + P_Q cal(H) P_M ket(Psi) = E P_Q ket(Psi) $
  Since $P^2 = P$, put one more projector next to the ket:
  $
    P_Q cal(H) P_Q ket(Psi) = (P_Q cal(H) P_Q)(P_Q ket(Psi)) = H_(Q Q) P_Q ket(Psi), quad P_Q cal(H) P_M ket(Psi) = hat(g)^dagger P_M ket(Psi)
  $
  $ arrow.r.double quad H_(Q Q) P_Q ket(Psi) + hat(g)^dagger P_M ket(Psi) = E P_Q ket(Psi) $
  Multiplying by $P_M$ instead: #h(0.3em) $hat(g) P_Q ket(Psi) + H_(M M) P_M ket(Psi) = E P_M ket(Psi)$. Collecting terms:
  #keybox[$
    (E - H_(Q Q)) P_Q ket(Psi) = hat(g)^dagger P_M ket(Psi), quad (E - H_(M M)) P_M ket(Psi) = hat(g) P_Q ket(Psi)
  $]
]

#slide[Task 1, Step 3: Eliminating the compact states][
  For $E != E_n$, with the inverse taken inside the compact space:
  $ P_Q ket(Psi) = (E - H_(Q Q))^(-1) hat(g)^dagger P_M ket(Psi) $
  Plug this into the second equation:
  $ (E - H_(M M)) P_M ket(Psi) = hat(g) (E - H_(Q Q))^(-1) hat(g)^dagger P_M ket(Psi) $
  $H_(Q Q) = sum_n E_n ket(n) bra(n)$ is diagonal, so on the compact space $(E - H_(Q Q))^(-1) = sum_n (ket(n) bra(n)) / (E - E_n)$:
  #keybox[$
    [H_(M M) + hat(V)(E)] P_M ket(Psi) = E P_M ket(Psi), quad hat(V)(E) = hat(g) (E - H_(Q Q))^(-1) hat(g)^dagger = sum_n (hat(g) ket(n) bra(n) hat(g)^dagger) / (E - E_n)
  $]
  A Schrödinger equation for the heavy mesons alone: the compact states leave behind an energy-dependent potential.
]

/* Plot of V(E), commented out.
#slide(refs: [plot: our estimate, full-fit $V_0 = 371.5$ MeV])[What $hat(V)(E)$ looks like][
  #grid(
    columns: (1.55fr, 1fr),
    column-gutter: 1em,
    align: horizon,
    v-of-e-plot(),
    [
      at zero momenta, with $N = 4$:
      $ V_S (0, 0; E) = sum_(n <= 4) (g^2 f_n (0)^2) / (E - E_n) $
      - poles at the bare energies $E_n = E_n^((0)) + V_0$ (dotted)
      - dashed: the individual terms
      - near threshold the $n = 3$ term dominates
      - attractive just below $E_3$, strongly repulsive between $E_3$ and threshold
    ],
  )
]
*/

#slide[Task 1, Step 4: Truncation and compact amplitudes][
  Split $P_Q = P_(<= N) + P_(> N)$:
  $
    hat(V)(E) = sum_(n <= N) (hat(g) ket(n) bra(n) hat(g)^dagger) / (E - E_n) + hat(g) P_(> N) (E - H_(Q Q))^(-1) P_(> N) hat(g)^dagger
  $
  - the second piece has no pole near threshold and varies slowly there
  - at LO it is replaced by a constant: the contact term $C(Lambda, N)$, which is why $C$ depends on $N$
  #v(0.6em)
  Projecting $P_Q ket(Psi) = (E - H_(Q Q))^(-1) hat(g)^dagger P_M ket(Psi)$ on $bra(n)$ gives the compact amplitudes:
  $ lambda_n = braket(n, Psi) = mel(n, hat(g)^dagger P_M, Psi) / (E - E_n) $
]

#slide[Task 1, Step 5: Normalisation and the compact probability][
  Bound state ($E = -E_B$, real), $ket(Psi_M) equiv P_M ket(Psi)$; $hat(g)$ does not depend on $E$, and
  $ partial_E (E - H_(Q Q))^(-1) = -(E - H_(Q Q))^(-2) $
  so
  $
    braket(Psi, Psi) & = mel(Psi, P_M, Psi) + mel(Psi, P_Q, Psi) = braket(Psi_M, Psi_M) + mel(Psi_M, hat(g) (E - H_(Q Q))^(-2) hat(g)^dagger, Psi_M) \
    & = mel(Psi_M, [1 - partial_E hat(V)(E)], Psi_M)
  $
  #keybox[$ cal(P)_(macron(b) b) = mel(Psi, P_Q, Psi) = sum_n |lambda_n|^2 = -mel(Psi_M, partial_E hat(V), Psi_M) $]
  The energy dependence of $hat(V)$ _is_ the compact component.
]






#slide[Task 2, Step 1: The BO coupling order][
  Two ways to couple $j_l = s_H = 1$ and $L$ to $J = 1$:
  $
    "partial waves:" & quad arrow(S) = arrow(j)_l + arrow(s)_H, quad arrow(J) = arrow(L) + arrow(S) & quad arrow.r quad & ket(L\, (j_l thin s_H) S\; J) \
    "BO:" & quad arrow(J)_l = arrow(L) + arrow(j)_l, quad arrow(J) = arrow(J)_l + arrow(s)_H & quad arrow.r quad & ket((L thin j_l) J_l\, s_H\; J)
  $
  - $L = 0$ gives $J_l = 1$; $L = 2$ gives $J_l = 1, 2, 3$, but $J_l = 3$ cannot couple with $s_H = 1$ to $J = 1$
  #grid(
    columns: (1fr, 1.25fr),
    column-gutter: 1.5em,
    align: horizon,
    align(center, table(
      columns: 5,
      align: center,
      toprule, [$J_l^(P_l C_l)$], [$|lambda_l|$], [$eta$], [$sigma$],
      [BO configuration], midrule, [$1^(- -)$], [0], [$g$],
      [$+$], [$Sigma_g^(+')$], [$1^(- -)$], [1], [$g$],
      [–], [$Pi_g\; 1$], [$2^(- -)$], [1], [$g$],
      [–], [$Pi_g\; 2$], bottomrule,
    )),
    [
      - $J_l = 2$, $lambda_l = 0$ is absent due to the CG coefficient
      $ braket(L = 2\, M_L = 0\; j_l = 1\, M_(j_l) = 0, J_l = 2\, 0) = 0 $
      - three BO configurations, as many as partial-wave channels
    ],
  )
  #v(0.25em)
  #align(center, text(size: 16pt)[$
    eta = P_l C_l = +1 quad (g), quad sigma = P_l (-1)^(J_l) = +1 quad (lambda_l = 0, J_l = 1)
  $])
]

#slide(refs: [Jacob, Wick, Ann. Phys. 7, 404 (1959)])[Task 2, Step 2: Jacob–Wick formula][
  The BO states have a definite projection $lambda_l$ of $arrow(j)_l$ on $hat(bold(r))$; the states $ket((L thin j_l) J_l thin M_l)$ have a definite $L$. Jacob–Wick connects them:
  #keybox[$
    ket(J_l thin M_l\; lambda_l) = sum_L sqrt((2L + 1) / (2 J_l + 1)) braket(L thin 0 thin j_l thin lambda_l, J_l thin lambda_l) ket((L thin j_l) J_l thin M_l)
  $]
  - the $0$: $arrow(L) dot hat(bold(r)) = 0$, so all of $lambda_l$ comes from $arrow(j)_l$; the coefficients do not depend on $M_l$
  - then a $6j$ symbol takes definite $L$ to the partial-wave channels:
  $
    underbrace(ket(J_l thin M_l\; lambda_l), "BO state") quad stretch(arrow.l.r, size: #4em)^"Step 1"_"Jacob–Wick" quad underbrace(ket((L thin j_l) J_l), "definite" L) quad stretch(arrow.l.r, size: #4em)^"Step 2"_(6j) quad underbrace(ket(L\, (j_l thin s_H) S\; J), "partial wave")
  $
  - next: derive the formula from the usual Clebsch–Gordan coupling
]

#slide[Deriving Jacob–Wick: start from Clebsch–Gordan][
  The usual CG coupling along a fixed axis $hat(z)$, written as a function of the direction $hat(bold(r))$ of the $b macron(b)$ axis (a light-spin state at each $hat(bold(r))$):
  $
    braket(hat(bold(r)), (L thin j_l) J_l thin M_l) = sum_(m_L, m_l) braket(L thin m_L thin j_l thin m_l, J_l thin M_l) Y_(L m_L)(hat(bold(r))) ket(j_l thin m_l)
  $
  - BO needs $lambda_l$, the projection of $arrow(j)_l$ on $hat(bold(r))$, not on the fixed $hat(z)$
  - look on the axis first, $hat(bold(r)) = hat(z)$: there $Y_(L m_L)(hat(z)) = sqrt((2L + 1) \/ 4 pi) thin delta_(m_L 0)$, because $Y_(L m) prop sin^(|m|) theta$. The orbital motion has no projection on its own direction ($arrow(L) dot hat(bold(r)) = 0$), so the CG sum collapses to the $m_L = 0$ term:
  #keybox[$
    braket(hat(z), (L thin j_l) J_l thin M_l) = sqrt((2L + 1) / (4 pi)) braket(L thin 0 thin j_l thin M_l, J_l thin M_l) ket(j_l thin M_l)
  $]
  - on the axis the projection on $hat(z)$ is the projection on $hat(bold(r))$: here $M_l = lambda_l$
]

#slide[Deriving Jacob–Wick: rotate away from the axis][
  $R$: the rotation taking $hat(z)$ to $hat(bold(r))$; $U(R) = U_"orb" (R) thin U_"spin" (R)$ rotates the direction and the light spin; $D^J_(M' M)(R) = mel(J thin M', U(R), J thin M)$.
  - a multiplet of definite $J$ is fixed by its values on the axis:
    $
      braket(R hat(z), J thin M) = sum_lambda D^(J*)_(M lambda)(R) thin U_"spin" (R) braket(hat(z), J thin lambda)
    $
    because $bra(R hat(z)) = bra(hat(z)) U_"orb"^dagger = bra(hat(z)) U_"spin" U^dagger$ and $U^dagger ket(J thin M) = sum_lambda D^(J*)_(M lambda) ket(J thin lambda)$
  - insert the axis values of the previous slide (there $M_l = lambda$):
  #keybox[$
    braket(hat(bold(r)), (L thin j_l) J_l thin M_l) = sqrt((2L + 1) / (4 pi)) sum_lambda braket(L thin 0 thin j_l thin lambda, J_l thin lambda) D^(J_l*)_(M_l lambda)(R) ket(j_l thin lambda)_(hat(bold(r)))
  $]
  - $ket(j_l thin lambda)_(hat(bold(r))) equiv U_"spin" (R) ket(j_l thin lambda)$ is the light spin with projection $lambda$ on $hat(bold(r))$
]

#slide[Deriving Jacob–Wick: identify the BO states and invert][
  Each term is a BO state, with definite $J_l$, $M_l$ and light projection $lambda$ on $hat(bold(r))$:
  $
    braket(hat(bold(r)), J_l thin M_l\; lambda) = sqrt((2 J_l + 1) / (4 pi)) D^(J_l*)_(M_l lambda)(R) ket(j_l thin lambda)_(hat(bold(r))), quad integral dif Omega thin |D^J_(M lambda)|^2 = (4 pi) / (2 J + 1)
  $
  So the previous slide reads
  $
    ket((L thin j_l) J_l thin M_l) = sum_lambda c_(L lambda) ket(J_l thin M_l\; lambda), quad c_(L lambda) = sqrt((2L + 1) / (2 J_l + 1)) braket(L thin 0 thin j_l thin lambda, J_l thin lambda)
  $
  - $c$ is real and links two orthonormal bases, so it is orthogonal, $c^(-1) = c^T$, which gives the formula of Step 1:
  #keybox[$
    ket(J_l thin M_l\; lambda_l) = sum_L sqrt((2L + 1) / (2 J_l + 1)) braket(L thin 0 thin j_l thin lambda_l, J_l thin lambda_l) ket((L thin j_l) J_l thin M_l)
  $]
]

#slide[Applying Jacob–Wick: the $lambda_l = 0$ states][
  - $J_l = 1$: #h(0.3em) $braket(0 thin 0 thin 1 thin 0, 1 thin 0) = 1$, #h(0.3em) $braket(1 thin 0 thin 1 thin 0, 1 thin 0) = 0$, #h(0.3em) $braket(2 thin 0 thin 1 thin 0, 1 thin 0) = -sqrt(2 \/ 5)$:
  $
    c_(0 0) = sqrt(1 / 3) dot 1 = 1 / sqrt(3), quad c_(1 0) = 0, quad c_(2 0) = sqrt(5 / 3) dot (-sqrt(2 / 5)) = -sqrt(2 / 3)
  $
  #keybox[$ ket(Sigma_g^(+')) = 1 / sqrt(3) ket((0 thin 1) 1) - sqrt(2 / 3) ket((2 thin 1) 1) $]
  - $J_l = 2$: #h(0.3em) $braket(1 thin 0 thin 1 thin 0, 2 thin 0) = sqrt(2 \/ 3)$, #h(0.3em) $braket(2 thin 0 thin 1 thin 0, 2 thin 0) = 0$, #h(0.3em) $braket(3 thin 0 thin 1 thin 0, 2 thin 0) = -sqrt(3 \/ 7)$:
  $
    ket(J_l = 2\, lambda_l = 0) = sqrt(3 / 5) sqrt(2 / 3) ket((1 thin 1) 2) - sqrt(7 / 5) sqrt(3 / 7) ket((3 thin 1) 2) = sqrt(2 / 5) ket((1 thin 1) 2) - sqrt(3 / 5) ket((3 thin 1) 2)
  $
  - only odd $L$, i.e. negative parity: besides the vanishing $L = 2$ CG coefficient there is no even-$L$ piece at all, so this state is absent
]

#slide[Applying Jacob–Wick: the $lambda_l = plus.minus 1$ states ($Pi_g$)][
  Same steps with $braket(L thin 0 thin 1 thin plus.minus 1, J_l thin plus.minus 1)$:
  - $J_l = 1$, $lambda_l = plus.minus 1$: #h(0.3em) $ket(plus.minus 1) = 1 / sqrt(3) ket((0 thin 1) 1) minus.plus 1 / sqrt(2) ket((1 thin 1) 1) + 1 / sqrt(6) ket((2 thin 1) 1)$ \
    the $L = 1$ piece has the wrong parity and is the one that flips sign, so the parity-even state is $(ket(+1) + ket(-1)) \/ sqrt(2)$:
    $ ket(Pi_g\; 1) = sqrt(2 / 3) ket((0 thin 1) 1) + 1 / sqrt(3) ket((2 thin 1) 1) $
  - $J_l = 2$, $lambda_l = plus.minus 1$: #h(0.3em) $ket(plus.minus 1) = sqrt(3 / 10) ket((1 thin 1) 2) minus.plus 1 / sqrt(2) ket((2 thin 1) 2) + 1 / sqrt(5) ket((3 thin 1) 2)$ \
    now the even-$L$ piece flips sign: the parity-even state is $(ket(+1) - ket(-1)) \/ sqrt(2) = -ket((2 thin 1) 2)$; dropping the overall sign (a convention), $ket(Pi_g\; 2) = ket((2 thin 1) 2)$
]

#slide[Task 2, Step 3: $6j$ recoupling at fixed $L$][
  To reach the partial-wave channels, move $j_l$ from $L$ over to $s_H$; the overlap is a $6j$ symbol:
  $
    braket((L thin j_l) J_l\, s_H\; J, L\, (j_l thin s_H) S\; J) = (-1)^(L + j_l + s_H + J) sqrt((2 J_l + 1)(2 S + 1)) mat(delim: "{", L, j_l, J_l; s_H, J, S)
  $
  - $L = 0$: nothing to do, $ket((0 thin 1) 1) = ket(pw(3, S, 1))$
  - $L = 2$: the phase is $(-1)^5 = -1$, and
  $
    mat(delim: "{", 2, 1, 1; 1, 1, 1) = 1 / 6, quad mat(delim: "{", 2, 1, 1; 1, 1, 2) = mat(delim: "{", 2, 1, 2; 1, 1, 1) = -sqrt(5) / 10, quad mat(delim: "{", 2, 1, 2; 1, 1, 2) = -1 / 10
  $
  e.g. $braket((2 thin 1) 1, pw(3, D, 1)) = -sqrt(3 dot 3) dot 1 \/ 6 = -1 \/ 2$. In total
  #keybox[$
    ket((2 thin 1) J_l = 1) = -1 / 2 ket(pw(3, D, 1)) + sqrt(3) / 2 ket(pw(5, D, 1)), quad ket((2 thin 1) J_l = 2) = sqrt(3) / 2 ket(pw(3, D, 1)) + 1 / 2 ket(pw(5, D, 1))
  $]
]

#slide[Task 2, Step 4: The transformation matrix][
  Insert Step 2 into Step 1 (the same for the other two rows), e.g.
  $
    ket(Sigma_g^(+')) = 1 / sqrt(3) ket(pw(3, S, 1)) - sqrt(2 / 3) (-1 / 2 ket(pw(3, D, 1)) + sqrt(3) / 2 ket(pw(5, D, 1))) = 1 / sqrt(3) ket(pw(3, S, 1)) + 1 / sqrt(6) ket(pw(3, D, 1)) - 1 / sqrt(2) ket(pw(5, D, 1))
  $
  #keybox[$
    mat(ket(Sigma_g^(+')); ket(Pi_g\; 1); ket(Pi_g\; 2)) = underbrace(mat(1 / sqrt(3), 1 / sqrt(6), -1 / sqrt(2); sqrt(2 / 3), -1 / (2 sqrt(3)), 1 / 2; 0, sqrt(3) / 2, 1 / 2), U) mat(ket(B macron(B)^* (pw(3, S, 1))); ket(B macron(B)^* (pw(3, D, 1))); ket(B^* macron(B)^* (pw(5, D, 1)))), quad U U^T = bold(1)
  $]
  - rows normalised ($1 / 3 + 1 / 6 + 1 / 2 = 2 / 3 + 1 / 12 + 1 / 4 = 3 / 4 + 1 / 4 = 1$) and orthogonal: two bases for the same three states
]




#slide[Task 3: The basis problem][
  - the lattice works in the $B macron(B)$ basis (two pseudoscalar static–light mesons), which is not ours
  - we need the coupling of a $1^(+ +)$ bottomonium to an $S$-wave $B macron(B)^*$ pair
  - to relate the two we need the BO symmetry, here a cylindrical symmetry
  #v(1.4em)
  Plan of the next slides:
  #v(0.6em)
  #align(center, grid(
    columns: 5,
    column-gutter: 0.8em,
    align: center + horizon,
    [$sqrt(2) g_l$ \ #text(size: 14pt, fill: gray-text)[lattice, $B macron(B)$]],
    $stretch(arrow.r, size: #5em)^(times 2)_("spin, " 9j)$,
    [$mel(Sigma_g^(+'), H, W)$ \ #text(size: 14pt, fill: gray-text)[normalised $Sigma_g^(+')$ pair]],
    $stretch(arrow.r, size: #6em)^(times 1 \/ sqrt(3))_("partial waves, " 6j)$,
    [$g = mel(B macron(B)^* (pw(3, S, 1)), H, W)$ \ #text(size: 14pt, fill: gray-text)[$S$-wave $B macron(B)^*$]],
  ))
]


/* BO static energies, commented out.
#slide(refs: [schematic after Berwein, Brambilla, Tarrús Castellà, Vairo, PRD 92, 114019 (2015)])[BO static energies][
  #grid(
    columns: (1.3fr, 1fr),
    column-gutter: 1.2em,
    align: horizon,
    bo-energies-sketch(),
    [
      - static energies $E^((0))_(Lambda_eta^sigma)(r)$ carry the BO labels
      - $Sigma_g^+$: the ground state of the gluon field, quarkonium
      - $Pi_u$, $Sigma_u^-$: excited gluon fields (hybrids)
      - gap $Delta tilde Lambda_"QCD"$ #h(0.2em) $>>$ #h(0.2em) level spacing $E tilde m_Q v^2$: the heavy quarks move in one static energy (Born–Oppenheimer)
    ],
  )
]
*/

#slide(refs: [Bulava _et al._ 2019, 2024])[Task 3, Step 1: The lattice coupling and the heavy-quark spin][
  - schematically $sqrt(2) g_l = mel(W, H_"mix", B macron(B))$; the $sqrt(2)$: isoscalar $ket(B macron(B)) = (ket(B_u macron(B)_u) + ket(B_d macron(B)_d)) \/ sqrt(2)$
  - $ket(W)$ inherits its quantum numbers from the interpolating operator
  $ cal(O)_W (y, x, t) = macron(Q)(y, t) (bold(gamma) dot arrow(r)) / r W(y, x, t) Q(x, t) $
  - $bold(gamma) dot arrow(r) \/ r$ gives $ket(1\, 0)$ for the heavy spin (projection 0 on the axis); heavy-quark spin is conserved (HQSS)
  #keybox[$ sqrt(2) g_l = -1 / 2 mel(W, H, 1_H\, 0\; 1_l\, 0) $]
  - to show this: $B macron(B)$ is coupled as $ket([(s_b j_(l 1))_0 (s_macron(b) j_(l 2))_0]_0)$; recouple it into $ket([(s_b s_macron(b))_(s_H) (j_(l 1) j_(l 2))_(j_l)]_0)$
]

#slide[Recoupling $B macron(B)$: the $9j$ symbol][
  For four angular momenta the recoupling coefficient is
  $
    & braket([(j_1 j_2) J_(12) thin (j_3 j_4) J_(34)] J, [(j_1 j_3) J_(13) thin (j_2 j_4) J_(24)] J) \
    & quad = sqrt((2 J_(12) + 1)(2 J_(34) + 1)(2 J_(13) + 1)(2 J_(24) + 1)) mat(delim: "{", j_1, j_2, J_(12); j_3, j_4, J_(34); J_(13), J_(24), J)
  $
  - here $j_1 = s_b$, $j_2 = j_(l 1)$, $j_3 = s_macron(b)$, $j_4 = j_(l 2)$, all equal to $1 \/ 2$
  - $J_(12) = J_(34) = 0$: both mesons are pseudoscalars; and $J = 0$
  - so $J_(13) = s_H$ and $J_(24) = j_l$ must couple to zero: #h(0.3em) $s_H = j_l equiv s in {0, 1}$
]

#slide[Evaluating the $9j$ symbol][
  A $9j$ symbol with a zero reduces to a $6j$ symbol:
  $
    mat(delim: "{", a, b, e; c, d, e; f, f, 0) = (-1)^(b + c + e + f) / sqrt((2e + 1)(2f + 1)) mat(delim: "{", a, b, e; d, c, f)
  $
  For us, with the elementary $6j$ symbol with a zero:
  $
    mat(delim: "{", 1\/2, 1\/2, 0; 1\/2, 1\/2, 0; s, s, 0) = (-1)^(1 + s) / sqrt(2s + 1) mat(delim: "{", 1\/2, 1\/2, 0; 1\/2, 1\/2, s), quad mat(delim: "{", 1\/2, 1\/2, 0; 1\/2, 1\/2, s) = (-1)^(1 + s) / 2
  $
  The signs cancel: $9j = 1 \/ (2 sqrt(2s + 1))$, and the coefficient is $sqrt((2s + 1)^2) dot 1 / (2 sqrt(2s + 1)) = sqrt(2s + 1) / 2$:
  #keybox[$ ket(B macron(B)) = 1 / 2 ket((0_H 0_l)_0) + sqrt(3) / 2 ket((1_H 1_l)_0) $]
]

#slide[Task 3, Step 2: The factor of 2 from projection on the axis][
  Open $(1_H 1_l)_0$ into projections on the axis:
  $
    ket((1_H 1_l)_0) = sum_m braket(1 thin m thin 1 thin um m, 0 thin 0) ket(1_H\, m) ket(1_l\, -m), quad braket(1 thin m thin 1 thin um m, 0 thin 0) = (-1)^(1 - m) / sqrt(3)
  $
  so the coefficient of $ket(1_H\, 0) ket(1_l\, 0)$ is $sqrt(3) \/ 2 dot (-1 \/ sqrt(3)) = -1 \/ 2$. Altogether
  $
    ket(B macron(B)) = 1 / 2 ket(0_l\, 0) ket(0_H\, 0) + 1 / 2 sum_(lambda_l = plus.minus 1, 0) (-1)^(lambda_l + 1) ket(1_l\, lambda_l) ket(1_H\, -lambda_l)
  $
  - the only part with $ket(1_H\, 0)$ is $ket(1_H\, 0\; 1_l\, 0)$, with coefficient $-1 \/ 2$
  #keybox[$mel(W, H, 1_H\, 0\; 1_l\, 0) = -2 sqrt(2) thin g_l$: #h(0.3em) the extra factor of 2]
]



#slide[Task 3, Step 3: From $Sigma_g^(+')$ to the $pw(3, S, 1)$ channel][
  This is still not what we want: we need $mel(B macron(B)^* (pw(3, S, 1)), H, W)$.
  - insert the completeness relation of the BO basis, $sum ket("BO") bra("BO")$ over ${Sigma_g^(+'), Pi_g\; 1, Pi_g\; 2}$
  - the string $W$ is $Sigma_g^+$ and the mixing conserves the BO quantum numbers, so only $Sigma_g^(+')$ survives (BO selection rule):
  $ mel(B macron(B)^* (pw(3, S, 1)), H, W) = braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')) mel(Sigma_g^(+'), H, W) $
  #v(0.3em)
  #keybox[#h(0.4em) $braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')) = 1 / sqrt(3)$ #h(1em) ]
]


#slide[Task 3, Step 4: The coupling $g$][
  As derived above: $braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')) = 1 \/ sqrt(3)$. \ Back to the projector insertion:
  $
    g equiv mel(B macron(B)^* (pw(3, S, 1)), H, W) = underbrace(braket(B macron(B)^* (pw(3, S, 1)), Sigma_g^(+')), 1 \/ sqrt(3)) underbrace(mel(Sigma_g^(+'), H, W), -2 sqrt(2) thin g_l)
  $
  #keybox[$
    |g| = underbrace(sqrt(2), "flavour") times underbrace(2, "spin") times underbrace(1 / sqrt(3), S "wave") times g_l = 2 / sqrt(3) sqrt(2) thin g_l = 57 "MeV" quad (g_l = 35 "MeV")
  $]
  - $mel(Sigma_g^(+'), H, W)$ is the mixing with the normalised $Sigma_g^(+')$ configuration; by HQSS it equals $mel(1_H\, 0\; 1_l\, 0, H, W) = -2 sqrt(2) thin g_l$ from the lattice
  - the sign does not matter, since $V^((macron(b) b)) prop g^2$
]

