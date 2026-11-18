# S40 adaptive tiling

Run: `julia --startup-file=no --project=code/Xb2Continuation code/Xb2Continuation/scripts/s40_tiling.jl`.

All energy/momentum coordinates and dimensional margins below and in the CSV are in MeV; slope is dimensionless. C5 is interval-rigorous in energy but **sampled along the path**, not interval-rigorous in momentum. Defaults: Lambda = 4 GeV, r_near = 0.1 GeV, n_sub = 8, qspacing = 0.001 GeV.

First certificate wall time: 0.692641978 s; compilation: 0.0 s; execution estimate: 0.692641978 s. End-to-end computation time (excluding package import): 289.276470163 s.

| Region | Sheet | Certified | Excluded | Certified area | Floor (MeV) | Runtime (s) |
|:--|:--|--:|--:|--:|--:|--:|
| A1 | (-,+,+) | 29 | 0 | 100.00000000% | 0.1 | 10.981 |
| A2 | (-,-,+) | 29 | 0 | 100.00000000% | 0.1 | 25.089 |
| B1 | (-,+,+) | 80 | 0 | 100.00000000% | 0.5 | 14.063 |
| B2 | (-,-,+) | 80 | 0 | 100.00000000% | 0.5 | 55.919 |
| C1 | (-,-,-) | 46 | 16 | 98.75000000% | 1 | 47.511 |
| C2 | (-,-,-) | 129 | 623 | 87.83203125% | 1 | 134.669 |

The initial-grid estimate multiplies the first certificate's non-compilation time by the initial cell count; it excludes refinement and is not a runtime bound. All requested floors are retained: A1/A2 = 0.1 MeV, B1/B2 = 0.5 MeV, C1/C2 = 1 MeV. Early S35 exclusions are inexpensive and do not justify assuming every refinement costs a full C5 evaluation.

Thresholds: VV = 0, PV = -45.23, PP = -90.46; E31 = 47.579407 MeV.

<!-- s40_metadata: {"thresholds":[0.0,-45.2300000000001,-90.4600000000002],"mu":[2662.375,2651.019270539132,2639.7599999999998],"E31":47.5794069999998} -->

## A1: (-,+,+)

Re [-90.46, -45.23], Im [-10, 0] MeV; initial = (10, 2); requested floor = 0.1 MeV; used floor = 0.1 MeV.

Area check: certified + excluded = 452.3 MeV²; relative error = 4.794172772432023e-16 (required ≤ 1e-9). Runtime: 10.980946347 s.

### Certified extrema

| Quantity | Minimum | Cell extent |
|:--|--:|:--|
| slope | 0.0034762503726 | Re [-45.795375, -45.23], Im [-0.625, 0] MeV |
| s35_margin | 92.48458783 | Re [-49.753, -45.23], Im [-10, -5] MeV |
| window_margin | 16.9479393293 | Re [-47.4915, -46.36075], Im [-2.5, -1.25] MeV |
| z_margin | 20.3691320146 | Re [-46.36075, -45.795375], Im [-1.25, -0.625] MeV |
| clearance | 53.9089035072 | Re [-46.36075, -45.795375], Im [-0.625, 0] MeV |

### Node sets

| Nodes | Certified cells |
|:--|--:|
| PP | 21 |
| PP (PV dropped) | 3 |
| PV+PP | 5 |

### Exclusions

Extents are bounding boxes of each reason's cells, not claims that the entire bounding box is excluded.

| Reason | Cells | Re extent (MeV) | Im extent (MeV) |
|:--|--:|:--|:--|
| none | 0 | — | — |

## A2: (-,-,+)

Re [-45.23, 0], Im [-10, 0] MeV; initial = (10, 2); requested floor = 0.1 MeV; used floor = 0.1 MeV.

Area check: certified + excluded = 452.3 MeV²; relative error = 1.1985431931080058e-16 (required ≤ 1e-9). Runtime: 25.089331694 s.

### Certified extrema

| Quantity | Minimum | Cell extent |
|:--|--:|:--|
| slope | 0.0034762503726 | Re [-0.565375, 0], Im [-0.625, 0] MeV |
| s35_margin | 47.2532023908 | Re [-4.523, 0], Im [-10, -5] MeV |
| window_margin | 16.6888667991 | Re [-2.2615, -1.13075], Im [-2.5, -1.25] MeV |
| z_margin | 21.8090729097 | Re [-2.2615, -1.13075], Im [-2.5, -1.25] MeV |
| clearance | 54.0242404199 | Re [-1.13075, -0.565375], Im [-0.625, 0] MeV |

### Node sets

| Nodes | Certified cells |
|:--|--:|
| PV+PP | 21 |
| PV+PP (VV dropped) | 3 |
| VV+PV+PP | 5 |

### Exclusions

Extents are bounding boxes of each reason's cells, not claims that the entire bounding box is excluded.

| Reason | Cells | Re extent (MeV) | Im extent (MeV) |
|:--|--:|:--|:--|
| none | 0 | — | — |

## B1: (-,+,+)

Re [-90.46, -45.23], Im [-50, -10] MeV; initial = (10, 8); requested floor = 0.5 MeV; used floor = 0.5 MeV.

Area check: certified + excluded = 1809.2 MeV²; relative error = 8.38980235175604e-16 (required ≤ 1e-9). Runtime: 14.062610764 s.

### Certified extrema

| Quantity | Minimum | Cell extent |
|:--|--:|:--|
| slope | 0.142501669003 | Re [-49.753, -45.23], Im [-15, -10] MeV |
| s35_margin | 82.2681125384 | Re [-49.753, -45.23], Im [-50, -45] MeV |
| window_margin | 101.769130017 | Re [-90.46, -85.937], Im [-15, -10] MeV |
| z_margin | 159.793514174 | Re [-49.753, -45.23], Im [-50, -45] MeV |
| clearance | 136.160808546 | Re [-49.753, -45.23], Im [-15, -10] MeV |

### Node sets

| Nodes | Certified cells |
|:--|--:|
| PP | 80 |

### Exclusions

Extents are bounding boxes of each reason's cells, not claims that the entire bounding box is excluded.

| Reason | Cells | Re extent (MeV) | Im extent (MeV) |
|:--|--:|:--|:--|
| none | 0 | — | — |

## B2: (-,-,+)

Re [-45.23, 0], Im [-50, -10] MeV; initial = (10, 8); requested floor = 0.5 MeV; used floor = 0.5 MeV.

Area check: certified + excluded = 1809.2 MeV²; relative error = 1.4382518317296068e-15 (required ≤ 1e-9). Runtime: 55.918893059 s.

### Certified extrema

| Quantity | Minimum | Cell extent |
|:--|--:|:--|
| slope | 0.142501669003 | Re [-4.523, 0], Im [-15, -10] MeV |
| s35_margin | 36.9931511456 | Re [-4.523, 0], Im [-50, -45] MeV |
| window_margin | 101.691861188 | Re [-45.23, -40.707], Im [-15, -10] MeV |
| z_margin | 69.4578736396 | Re [-4.523, 0], Im [-50, -45] MeV |
| clearance | 136.4521216 | Re [-4.523, 0], Im [-15, -10] MeV |

### Node sets

| Nodes | Certified cells |
|:--|--:|
| PV+PP | 80 |

### Exclusions

Extents are bounding boxes of each reason's cells, not claims that the entire bounding box is excluded.

| Reason | Cells | Re extent (MeV) | Im extent (MeV) |
|:--|--:|:--|:--|
| none | 0 | — | — |

## C1: (-,-,-)

Re [0, 47.579407], Im [-10, 0] MeV; initial = (10, 2); requested floor = 1 MeV; used floor = 1 MeV.

Area check: certified + excluded = 475.79407 MeV²; relative error = 1.2532968199183946e-15 (required ≤ 1e-9). Runtime: 47.510945519 s.

### Certified extrema

| Quantity | Minimum | Cell extent |
|:--|--:|:--|
| slope | 0.00334669755949 | Re [46.389921825, 46.9846644125], Im [-0.625, 0] MeV |
| s35_margin | 0.0932453048632 | Re [46.389921825, 46.9846644125], Im [-10, -9.375] MeV |
| window_margin | 68.942615494 | Re [0, 4.7579407], Im [-5, 0] MeV |
| z_margin | 46.8532624677 | Re [46.389921825, 46.9846644125], Im [-10, -9.375] MeV |
| clearance | Inf | Re [0, 4.7579407], Im [-10, -5] MeV |

### Node sets

| Nodes | Certified cells |
|:--|--:|
| VV+PV+PP | 46 |

### Exclusions

Extents are bounding boxes of each reason's cells, not claims that the entire bounding box is excluded.

| Reason | Cells | Re extent (MeV) | Im extent (MeV) |
|:--|--:|:--|:--|
| C2: S35 margin is nonpositive | 16 | [46.9846644125, 47.579407] | [-10, 0] |

## C2: (-,-,-)

Re [0, 47.579407], Im [-50, -10] MeV; initial = (10, 8); requested floor = 1 MeV; used floor = 1 MeV.

Area check: certified + excluded = 1903.17628 MeV²; relative error = 2.1647854162226814e-15 (required ≤ 1e-9). Runtime: 134.669422682 s.

### Certified extrema

| Quantity | Minimum | Cell extent |
|:--|--:|:--|
| slope | 0.109127031759 | Re [46.389921825, 46.9846644125], Im [-10.625, -10] MeV |
| s35_margin | 0.0192622687232 | Re [35.68455525, 36.2792978375], Im [-46.25, -45.625] MeV |
| window_margin | 100.111145563 | Re [0, 4.7579407], Im [-15, -10] MeV |
| z_margin | 46.852728762 | Re [46.389921825, 46.9846644125], Im [-10.625, -10] MeV |
| clearance | Inf | Re [0, 4.7579407], Im [-50, -45] MeV |

### Node sets

| Nodes | Certified cells |
|:--|--:|
| VV+PV+PP | 129 |

### Exclusions

Extents are bounding boxes of each reason's cells, not claims that the entire bounding box is excluded.

| Reason | Cells | Re extent (MeV) | Im extent (MeV) |
|:--|--:|:--|:--|
| C2: S35 margin is nonpositive | 623 | [33.9003274875, 47.579407] | [-50, -10] |

