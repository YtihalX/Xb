# /// script
# requires-python = ">=3.12"
# dependencies = ["numpy>=2.1", "scipy>=1.14", "matplotlib>=3.9"]
# ///
"""Three page-width views of the same continuation; no dynamics or pole assumptions.

Run: uv run --script notes/05-singularity-map/fig_overview.py
The k1 imaginary viewport is ±400 MeV: the exact path lies above 347i MeV,
so a ±300 MeV viewport would hide it. Real k1 remains in [−300,300] MeV.
"""
from pathlib import Path
import json
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from kinematics import M_PI, SECTOR_2PP, momentum, momenta
from loop_plane import graph_contour

HERE = Path(__file__).resolve().parent
FIGURES = HERE/"figures"
plt.rcParams.update({"font.size":12,"axes.titlesize":12,"axes.labelsize":12,
                     "xtick.labelsize":12,"ytick.labelsize":12})
COLORS = {1:"#2257a0",5:"#ca6323",6:"#198564"}
E = -.02262-.01j
SHEET = (-1,-1,1)


def arrow_on_curve(ax, z, color="crimson", ls="-", lw=1.5):
    ax.plot(z.real,z.imag,ls=ls,color=color,lw=lw)
    ax.annotate("",xy=(z[-1].real,z[-1].imag),xytext=(z[-4].real,z[-4].imag),
                arrowprops={"arrowstyle":"->","color":color,"lw":lw})


def render():
    data=json.loads((HERE/"loop-plane-data.json").read_text())
    record=next(r for r in data["probes"] if r["E_MeV"]==[-22.62,-10.0])
    contour=graph_contour(E,SHEET,*record["parameters"])
    fig=plt.figure(figsize=(10,6.4))
    centers=(.185,.515,.845)
    axes=[fig.add_axes([c-.11,.36,.22,.44]) for c in centers]
    for ax in axes:
        ax.axhline(0,color=".65",lw=.65);ax.axvline(0,color=".65",lw=.65)
        ax.grid(alpha=.1)
    for x,text in zip(centers,("choose E","choose momentum\nbranches","choose loop\ncontour")):
        fig.text(x,.935,text,ha="center",va="center",fontsize=12)
    for start,end in ((.27,.40),(.60,.73)):
        axes[0].annotate("",xy=(end,.935),xytext=(start,.935),xycoords=fig.transFigure,
                         textcoords=fig.transFigure,arrowprops={"arrowstyle":"->","lw":1.3},annotation_clip=False)

    ax=axes[0]
    ax.set(xlim=(-110,60),ylim=(-40,20),xlabel="Re E [MeV]",ylabel="Im E [MeV]",title="energy plane")
    ax.set_xticks([-90,0,60]);ax.set_yticks([-40,0,20])
    # All three physical-sheet rhc coincide on the real axis. Nested line
    # widths show the coincident cuts without shifting their imaginary parts.
    for index,width in ((6,5),(5,3.2),(1,1.7)):
        threshold=1000*SECTOR_2PP.channel(index).delta
        ax.plot([threshold,60],[0,0],color=COLORS[index],lw=width,solid_capstyle="butt")
        ax.scatter([threshold],[0],s=30,color=COLORS[index],zorder=5)
        label=f"{threshold:.2f}" if index!=1 else "0"
        ax.text(threshold+(2 if index==6 else 0),12 if index==5 else 5,label,color=COLORS[index],
                ha="left" if index==6 else "center",fontsize=12)
    energy_path=np.full(81,-22.62)+1j*np.linspace(1e-7,-10,81)
    arrow_on_curve(ax,energy_path,ls="--")
    ax.annotate("probe,\nnot a pole",xy=(-22.62,-10),xytext=(-103,-27),fontsize=12,color="crimson",
                arrowprops={"arrowstyle":"->","color":"crimson"})
    fig.text(centers[0],.235,"Physical sheet above axis.\nDownward between\nBB* and B*B*\n→ (−,−,+).",
             ha="center",va="top",fontsize=12,linespacing=1.25)

    ax=axes[1]
    ax.set(xlim=(-300,300),ylim=(-400,400),xlabel="Re k₁ [MeV]",ylabel="Im k₁ [MeV]",title="momentum plane")
    ax.set_xticks([-300,0,300]);ax.set_yticks([-400,0,400])
    for x,y,label in ((160,190,"Q1\n(+,+,+)"),(-160,190,"Q2\n(−,−,+)"),
                      (-160,-205,"Q3\n(+,+,−)"),(160,-205,"Q4\n(−,−,−)")):
        ax.text(x,y,label,ha="center",va="center",fontsize=12)
    k_path=1000*momentum(SECTOR_2PP.channel(1),energy_path/1000,+1)
    arrow_on_curve(ax,k_path,ls="--")
    ax.scatter([0],[M_PI*500],s=15,marker="D",color="#7651a8",zorder=6)
    ax.annotate("69.02i",(0,M_PI*500),xytext=(-275,25),color="#7651a8",fontsize=12,
                arrowprops={"arrowstyle":"-","color":"#7651a8"})
    second=np.linspace(215+0j,215-90j,25)
    arrow_on_curve(ax,second,color=".25",lw=1.2)
    fig.text(centers[1],.235,"69.02i: on-shell\nexchange cut — not a\npole-search barrier.\nAbove threshold ↓\n→ (−,−,−).",
             ha="center",va="top",fontsize=12,linespacing=1.25)

    ax=axes[2]
    ax.set(xlim=(-100,800),ylim=(-400,400),xlabel="Re q [MeV]",ylabel="Im q [MeV]",title="loop plane")
    ax.set_xticks([0,400,800]);ax.set_yticks([-400,0,400])
    ks=momenta(SECTOR_2PP,E,SHEET)
    for index in (1,5,6):
        z=1000*complex(ks[index])
        ax.scatter([z.real],[z.imag],s=35,color=COLORS[index],zorder=6)
        ax.annotate(f"k{index}",(z.real,z.imag),xytext=(4,7),textcoords="offset points",color=COLORS[index],fontsize=12)
    z=-1000*complex(ks[1])
    ax.scatter([z.real],[z.imag],s=35,facecolors="white",edgecolors=COLORS[1],lw=1.2,zorder=6)
    ax.annotate("−k1",(z.real,z.imag),xytext=(4,6),textcoords="offset points",color=COLORS[1],fontsize=12)
    ax.plot(contour.real*1000,contour.imag*1000,color="black",lw=1.7)
    edge_y=np.interp(.8,contour.real,contour.imag)*1000
    ax.annotate("",xy=(850,edge_y),xytext=(690,edge_y),arrowprops={"arrowstyle":"->","color":"black"},annotation_clip=False)
    ax.text(.98,.27,"→ Λ",transform=ax.transAxes,ha="right",fontsize=12)
    fig.text(centers[2],.235,"Same probe energy:\n−22.62 − 10i MeV.\nC passes below k5,k6\nand above −k1.",
             ha="center",va="top",fontsize=12,linespacing=1.25)

    FIGURES.mkdir(exist_ok=True)
    fig.savefig(FIGURES/"overview.png",dpi=200)
    plt.close(fig)
    print("Probe E [MeV] =",1000*E,"; sheet =",SHEET)
    print("Exact threshold images [MeV] =",{i:1000*SECTOR_2PP.channel(i).delta for i in (6,5,1)})
    print("Exact k1 path endpoints [MeV] =",k_path[0],k_path[-1])
    print("Exact q-plane k [MeV] =",{i:1000*complex(k) for i,k in ks.items()})


if __name__=="__main__":
    render()
