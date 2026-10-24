// Build: typst compile main.typ   (figures in figs/ are symlinks into ../figs and Figs.dir)
#import "style.typ": *

#set document(title: "BOχEFT and its application to Xb", author: "Yu Zhang")
#show: deck

#title-slide(
  [BO$chi$EFT and its application to $X_b$],
  [Yu Zhang],
  [Institute of Theoretical Physics, Chinese Academy of Sciences \
    University of Chinese Academy of Sciences],
)

#include "sections/potential.typ"
#include "sections/lattice.typ"
#include "sections/bo.typ"
#include "sections/spin.typ"
#include "sections/partial-waves.typ"
