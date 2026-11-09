# /// script
# requires-python = ">=3.12"
# dependencies = ["numpy>=2.1", "sympy>=1.13", "mpmath>=1.3", "matplotlib>=3.9", "scipy>=1.14", "pillow>=11"]
# ///
"""Principal ratio-log cuts versus half-plane continuation of split logs."""
from pathlib import Path
import json
import sys
import numpy as np
from scipy.optimize import brentq
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from PIL import Image
from kinematics import SECTOR_2PP as S, momentum
from lhc_onshell import coefficients, roots, tracked_moments, path_to, principal_moments

HERE=Path(__file__).resolve().parent
plt.rcParams.update({'font.size':11})
SEAM_COLOR='#ad4b9f'


def curve(out,inc,meson):
    # Trace the preimage of the principal ratio-log's negative real axis.
    # x0=A/B must be real and between -1 and +1. The spurious closed curve
    # is traced by fixing Im E and bracketing Im x0=0 near the real A=0 point.
    xx=np.linspace(-.21,.03,2201)
    pts=[]
    for y in np.linspace(1e-7,.16,1800):
        A,B=coefficients(xx+1j*y,out,inc,meson)
        z=A/B
        choices=np.where(z.imag[:-1]*z.imag[1:]<0)[0]
        for j in choices:
            x=brentq(lambda x:float((coefficients(x+1j*y,out,inc,meson)[0]/coefficients(x+1j*y,out,inc,meson)[1]).imag),xx[j],xx[j+1],xtol=1e-14)
            aa,bb=coefficients(x+1j*y,out,inc,meson)
            if abs((aa/bb).real)<=1+1e-8:pts.append(x+1j*y)
    return np.array(pts)


fig,axs=plt.subplots(2,2,figsize=(14,12))
report=[]
for row,(out,inc,label) in enumerate([(1,5,'VV–PV π'),(1,6,'VV–PP π')]):
    bp=roots(out,inc,'pi')[0].real
    low=S.channel(inc).delta
    c=curve(out,inc,'pi')
    azero=brentq(lambda e:coefficients(e,out,inc,'pi')[0].real,low+.0001,-.00001)
    ax,kax=axs[row]
    for sign in (-1,1):
        z=c.real+sign*1j*c.imag
        ax.plot(z.real*1000,z.imag*1000,color=SEAM_COLOR,lw=2,ls='--')
        # All four momentum images; these are a representation seam, not new endpoints.
        k=momentum(S.channel(1),z)*1000
        for ks in (-1,1):kax.plot(ks*k.real,ks*k.imag,color=SEAM_COLOR,lw=2,ls='--')
    for axis in (ax,kax):
        axis.axhline(0,color='.7',lw=.8);axis.axvline(0,color='.7',lw=.8)
        axis.grid(alpha=.14)
    ax.plot([-800,bp*1000],[0,0],color='#0072B2',lw=3)
    for dy in (-1.6,1.6):ax.plot([bp*1000,low*1000],[dy,dy],color='#0072B2',lw=1.7)
    ax.scatter([bp*1000],[0],c='#0072B2',s=50,zorder=7)
    ax.scatter([azero*1000],[0],c=SEAM_COLOR,s=45,zorder=7)
    ax.annotate(f'A=0: {azero*1000:.2f} MeV\nnot a branch point',(azero*1000,0),xytext=(8,25),textcoords='offset points',fontsize=9)
    ax.axvline(low*1000,color='.5',ls='--',lw=1)
    ax.text(low*1000+2,-105,'lower threshold',fontsize=9,rotation=90,color='.4')
    if bp*1000 < -200:ax.text(-196,-20,f'endpoint {bp*1000:.2f} MeV\n(left of this zoom)',fontsize=9,color='#0072B2')
    else:ax.annotate(f'endpoint {bp*1000:.2f}',(bp*1000,0),xytext=(0,-28),textcoords='offset points',fontsize=9,color='#0072B2')
    # Exact axis images of the real genuine cut, with the doubled segment paired.
    for a,b,double in [(-2,bp,False),(bp,low,True)]:
        kk=momentum(S.channel(1),np.linspace(a,b,700))*1000
        for sign in (-1,1):
            for shift in ((-12,12) if double else (0,)):
                kax.plot(sign*kk.real+shift,sign*kk.imag,color='#0072B2',lw=1.3 if double else 2)
    for ee in (bp,low):
        kk=complex(momentum(S.channel(1),ee)*1000)
        if abs(kk)<1200:kax.scatter([kk.real,-kk.real],[kk.imag,-kk.imag],c='#0072B2',s=35)
    image=complex(momentum(S.channel(1),low)*1000)
    threshold_label='BB* threshold image' if inc==5 else 'BB threshold image'
    kax.annotate(f'{threshold_label}\n{image.imag:.2f}i',(0,image.imag),
                 xytext=(28,-18),textcoords='offset points',fontsize=11,
                 color='#0072B2',arrowprops={'arrowstyle':'-','lw':.6,'color':'#0072B2'})
    if inc==5:
        endpoint=complex(momentum(S.channel(1),bp)*1000)
        kax.annotate(f'VV–PV π endpoint\n{endpoint.imag:.2f}i',(0,endpoint.imag),
                     xytext=(28,8),textcoords='offset points',fontsize=11,
                     color='#0072B2',arrowprops={'arrowstyle':'-','lw':.6,'color':'#0072B2'})
    ax.set(xlim=(-200,20),ylim=(-120,120),xlabel='Re E [MeV]',ylabel='Im E [MeV]',title=label+': energy plane')
    kax.set(xlim=(-650,650),ylim=(-1200,1200),aspect='equal',xlabel=r'Re $k_{B^*\bar B^*}$ [MeV]',ylabel=r'Im $k_{B^*\bar B^*}$ [MeV]',title=label+r': $k_{B^*\bar B^*}$ plane')
    ax.text(-190,96,'branch tracking removes the magenta seam',color=SEAM_COLOR,fontsize=9)
    # Overview inset makes the closed loop visible instead of only its zoomed arc.
    inset=ax.inset_axes([.035,.61,.38,.24])
    xmax,ymax=(-.38,.18) if inc==5 else (-1.42,.72)
    X,Y=np.meshgrid(np.linspace(xmax,.01,801),np.linspace(-ymax,ymax,602))
    aa,bb=coefficients(X+1j*Y,out,inc,'pi')
    xzero=aa/bb
    field=np.ma.masked_where(abs(xzero.real)>1,xzero.imag)
    inset.contour(X*1000,Y*1000,field,levels=[0],colors=[SEAM_COLOR],linewidths=1.2,linestyles='--')
    inset.axhline(0,color='.65',lw=.5)
    inset.set(xticks=[int(xmax*1000),0],yticks=[0],title='complete principal seam (MeV)')
    inset.tick_params(labelsize=7)
    inset.title.set_fontsize(8)
    # Probe across the upper part of the representation seam at Im E=10 MeV.
    y=.010
    aa,bb=coefficients(np.linspace(-.19,.01,10001)+1j*y,out,inc,'pi')
    vals=(aa/bb).imag;xx=np.linspace(-.19,.01,10001)
    inds=np.where(vals[:-1]*vals[1:]<0)[0]
    for j in inds:
        xc=brentq(lambda x:float((coefficients(x+1j*y,out,inc,'pi')[0]/coefficients(x+1j*y,out,inc,'pi')[1]).imag),xx[j],xx[j+1])
        a,b=coefficients(xc+1j*y,out,inc,'pi')
        if abs((a/b).real)>1:continue
        samples=[]
        for eps in (1e-6,1e-7,1e-8):
            left,right=xc-eps+1j*y,xc+eps+1j*y
            pl=principal_moments(left,out,inc,'pi');pr=principal_moments(right,out,inc,'pi')
            tl=tracked_moments(path_to(left,1),out,inc,'pi')[0,-1]
            tr=tracked_moments(path_to(right,1),out,inc,'pi')[0,-1]
            samples.append({'epsilon_GeV':eps,'principal_difference_abs':float(abs(pr-pl)),
                            'tracked_difference_abs':float(abs(tr-tl)),
                            'principal_jump_limit_2pi_over_absB':float(2*np.pi/abs(b))})
        report.append({'transition':label,'A_zero_E_MeV':azero*1000,'seam_probe_E_MeV':[xc*1000,y*1000],
                       'principal_loop_samples':len(c),'seam_crossings':samples})
fig.legend(handles=[Line2D([],[],color=SEAM_COLOR,lw=2,ls='--',label='principal Log ratio / fixed real-x integration seam'),Line2D([],[],color='#0072B2',lw=3,label='genuine continued cut (paired = doubled)')],loc='lower center',ncol=1,bbox_to_anchor=(.5,.01))
fig.suptitle('Case-3 scalar angular moments: a branch-choice seam is not a new singularity',fontsize=15)
fig.tight_layout(rect=(0,.075,1,.96))
fig.savefig(HERE/'figures/lhc-representation.png',dpi=200)
if '--page-preview' in sys.argv:
    preview=Path('/tmp/lhc-page-previews')
    preview.mkdir(exist_ok=True)
    with Image.open(HERE/'figures/lhc-representation.png') as image:
        image.resize((1000,round(image.height*1000/image.width)),Image.Resampling.LANCZOS).save(preview/'lhc-representation.png')
(HERE/'data/lhc_representation.json').write_text(json.dumps(report,indent=2)+'\n')
for item in report:print(json.dumps(item,indent=2))
