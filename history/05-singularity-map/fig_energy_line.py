# /// script
# requires-python = ">=3.12"
# dependencies = ["numpy>=2.1", "matplotlib>=3.9"]
# ///
"""Thresholds and genuine on-shell cuts; no assumed pole energies."""
import json
from pathlib import Path
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from kinematics import SECTOR_2PP, three_body_thresholds, M_BS, M_BS_STAR

HERE=Path(__file__).resolve().parent
DATA=json.loads((HERE/"data/lhc_onshell.json").read_text())
COLORS={"VV–VV":"#0072B2","PV–PV":"#009E73","VV–PV":"#D55E00","VV–PP":"#CC79A7"}
plt.rcParams.update({"font.size":10,"axes.spines.top":False,"axes.spines.right":False})
fig,(ax,wide)=plt.subplots(2,1,figsize=(15,12),gridspec_kw={"height_ratios":[5,1.9]})
labels=[]
y=0
thresholds=[("BB",-90.46),("BB*",-45.23),("B*B*",0)]
for label,t in thresholds:
    labels.append(f"{label}  two-body rhc")
    ax.plot([t,165],[y,y],color="#444444",lw=3)
    ax.scatter(t,y,c="black",s=22,zorder=5)
    ax.text(t+1,y+.18,f"{t:+.2f}",fontsize=8)
    y+=1
three=three_body_thresholds(SECTOR_2PP)
for (pair,phi),t in three.items():
    if phi!="pi":continue
    t*=1000
    labels.append(f"{pair}π  three-body")
    ax.plot([t,165],[y,y],color="#8064a2",lw=3,ls="--")
    ax.scatter(t,y,c="#8064a2",marker="^",s=35)
    ax.text(t+1,y+.18,f"{t:+.2f}",fontsize=8)
    y+=1
for row in DATA["entries"]:
    name,meson=row["transition"],row["meson"]
    bp=row["roots"][0]["E_MeV"][0]
    low=1000*min(SECTOR_2PP.channel(row["out"]).delta,SECTOR_2PP.channel(row["in"]).delta)
    color=COLORS[name]
    labels.append(f"{name}  {'π' if meson=='pi' else 'η'}  lhc (Case {row['cut_case']})")
    end=low if row["cut_case"]==3 else bp
    ax.plot([-125,min(bp,160)],[y,y],color=color,lw=3)
    if row["cut_case"]==3:
        for dy in (-.075,.075):ax.plot([max(bp,-125),end],[y+dy,y+dy],color=color,lw=2.3)
        ax.plot([end,end],[y-.10,y+.10],color=color,lw=1)
    if bp>=-120:
        ax.scatter(bp,y,c=color,s=30,zorder=5)
        ax.text(bp+1,y+.38,f"{bp:.3f}",color=color,fontsize=8)
    else:
        ax.text(-118,y+.38,f"branch point {bp:.3f} MeV (wide strip below)",color=color,fontsize=8)
    y+=1
strange=[("BₛB̄ₛ",2*M_BS),('BₛB̄ₛ*',M_BS+M_BS_STAR),('Bₛ*B̄ₛ*',2*M_BS_STAR)]
for name,m in strange:
    e=(m-SECTOR_2PP.M_th)*1000
    ax.axvline(e,color=".65",lw=1,ls=":")
    if e<160:ax.text(e+.7,-.8,f"{name}\n{e:.2f}",fontsize=8,color=".4",ha="left")
ax.text(-117,-.85,"grey thresholds: not in the model; Bₛ*B̄ₛ* at +181.30 MeV is off this panel",ha="left",fontsize=9,color=".4")
ax.set(xlim=(-120,160),ylim=(y-.3,-1.3),yticks=range(y),yticklabels=labels,xlabel=r"$E=M-2m_{B^*}$ [MeV]",title="Energy map: right-hand cuts and genuinely continued on-shell OME left-hand cuts")
ax.grid(axis="x",alpha=.17)
for label,t in thresholds:wide.axvline(t,color=".75",lw=.8,zorder=-2)
wide_labels=[]
for j,row in enumerate(DATA["entries"]):
    bp=row['roots'][0]['E_MeV'][0]; c=COLORS[row['transition']]
    yy=j
    wide_labels.append(f"{row['transition']}  {'π' if row['meson']=='pi' else 'η'}  lhc (Case {row['cut_case']})")
    end=1000*min(SECTOR_2PP.channel(row['out']).delta,SECTOR_2PP.channel(row['in']).delta) if row['cut_case']==3 else bp
    wide.plot([-800,bp],[yy,yy],color=c,lw=1.8)
    if row['cut_case']==3:
        for dy in (-.07,.07):wide.plot([bp,end],[yy+dy,yy+dy],color=c,lw=1.3)
    wide.scatter(bp,yy,c=c,s=15)
    if bp<-120:wide.text(bp+4,yy+.37,f"{bp:.2f} MeV",fontsize=8,color=c,va="top")
eta_lane=8
for (pair,phi),t in three.items():
    if phi=='eta':
        e=t*1000
        wide_labels.append(f"{pair}η  three-body")
        wide.plot([e,600],[eta_lane,eta_lane],color='#8064a2',ls='--',lw=1.5)
        wide.scatter(e,eta_lane,c='#8064a2',marker='^',s=22)
        wide.text(e+4,eta_lane+.37,f"{e:.2f} MeV",fontsize=8,color='#8064a2',va="top")
        eta_lane+=1
wide.set(xlim=(-800,600),ylim=(10.8,-.65),yticks=range(len(wide_labels)),yticklabels=wide_labels,
         xlabel=r"$E$ [MeV]",title="Wide strip: deeper physical branch points and η three-body thresholds")
wide.tick_params(axis='y',labelsize=8)
wide.grid(axis='x',alpha=.15)
fig.text(.02,.012,"Scalar moments: single line |Disc Δ₀| = 2π/|B|; paired = doubled. Projected strengths / threshold powers not shown. Far recoil roots outside this strip: see JSON.",fontsize=9)
fig.tight_layout(rect=(0,.035,1,1))
(HERE/'figures').mkdir(exist_ok=True)
fig.savefig(HERE/'figures/energy-line.png',dpi=200)
