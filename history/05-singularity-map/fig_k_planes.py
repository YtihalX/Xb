# /// script
# requires-python = ">=3.12"
# dependencies = ["numpy>=2.1", "matplotlib>=3.9", "pillow>=11"]
# ///
"""On-shell momentum charts and their external Markdown keys.

Use --page-preview to also write 1000-pixel-wide review images under
/tmp/lhc-page-previews. The physics input remains lhc_onshell.json.
"""
import json
from pathlib import Path
import sys
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.patches import Circle, Wedge
from PIL import Image
from kinematics import SECTOR_2PP as S, momentum, sheet_of, three_body_thresholds

HERE=Path(__file__).resolve().parent
DATA=json.loads((HERE/'data/lhc_onshell.json').read_text())
COLORS={'VV–VV':'#0072B2','PV–PV':'#009E73','VV–PV':'#D55E00','VV–PP':'#CC79A7'}
NAMES={1:r'$k_{B^*\bar B^*}$',5:r'$k_{B\bar B^*}$',6:r'$k_{B\bar B}$'}
plt.rcParams.update({'font.size':13,'axes.labelsize':14,'xtick.labelsize':13,'ytick.labelsize':13})


def mapped(E,index):
    return np.asarray(momentum(S.channel(index),np.asarray(E)/1000)*1000)


def save_figure(fig,filename):
    path=HERE/'figures'/filename
    fig.savefig(path,dpi=200)
    if '--page-preview' in sys.argv:
        preview=Path('/tmp/lhc-page-previews')
        preview.mkdir(exist_ok=True)
        with Image.open(path) as image:
            image.resize((1000,round(image.height*1000/image.width)),Image.Resampling.LANCZOS).save(preview/filename)
    plt.close(fig)


def lane(ax,z,offset,color,lw=1.5,ls='-'):
    """Displace parallel lanes only; all endpoint markers remain exact."""
    z=np.asarray(z)
    imag=abs(z.imag)>abs(z.real)+1e-6
    ax.plot(z.real+np.where(imag,offset,0),z.imag+np.where(imag,0,offset),color=color,lw=lw,ls=ls)


def local_sheet_disc(ax,index,lim):
    radius=min(abs(complex(mapped(S.channel(other).delta*1000,index)))
               for _,other in S.thresholds if other!=index)
    shades=(['#e8f3f8','#e8f3f8','#f3e9f6','#f3e9f6'] if index==6 else
            ['#e8f3f8','#f8eee7','#f3e9f6','#eaf3e5'])
    full_view=radius>np.sqrt(2)*lim
    for j,(sx,sy) in enumerate([(1,1),(-1,1),(-1,-1),(1,-1)]):
        ax.add_patch(Wedge((0,0),radius,j*90,(j+1)*90,facecolor=shades[j],edgecolor='none',zorder=-9))
        signs=sheet_of(S,index,(sx+sy*1j)*.035)
        label='('+','.join('+' if int(s)>0 else '−' for s in signs)+')'
        if index!=6 or sx<0:
            x,y=(sx*.55*lim,sy*.72*lim) if full_view else (sx*.60*radius,sy*.42*radius)
            ax.text(x,y,label,ha='center',fontsize=12,color='.35')
    ax.add_patch(Circle((0,0),radius,facecolor='none',edgecolor='.55',lw=.8,zorder=-2))
    if full_view:
        ax.text(-.95*lim,.91*lim,'quadrant = sheet inside',fontsize=10,color='.4')
    else:
        ax.annotate('quadrant = sheet inside',(-radius/np.sqrt(2),radius/np.sqrt(2)),
                    xytext=(-1030,850),fontsize=11,color='.4',
                    arrowprops={'arrowstyle':'-','color':'.55','lw':.6})
    return radius


def tagged_marker(ax,z,tag,color,marker,lim):
    """Tag one ± pair. Deep OME endpoints are listed only in the table."""
    offscale=abs(z)>lim
    if offscale and tag>=10:
        return True
    if offscale:
        # A single positive-direction arrow per off-scale three-body object.
        shift=-95*(tag-7)*1j
        direction=z/abs(z)
        point=direction*(lim-45)+shift
        ax.annotate('',xy=(direction.real*(lim-18),direction.imag*(lim-18)+shift.imag),
                    xytext=(direction.real*(lim-110),direction.imag*(lim-110)+shift.imag),
                    arrowprops={'arrowstyle':'-|>','color':color,'lw':1.2})
        dx,dy=-10,12
    else:
        for sign in (-1,1):
            ax.scatter(sign*z.real,sign*z.imag,s=40,c=color,marker=marker,zorder=8)
        point=z
        if abs(z.imag)>abs(z.real):
            shifts={1:(-48,12),2:(-42,-4),3:(-48,12),10:(24,6),11:(24,6),
                    12:(-55,-30),13:(-50,4),14:(24,6),15:(48,8),17:(24,-8)}
        else:
            shifts={1:(-30,18),2:(24,13),3:(4,58),10:(32,72),11:(30,-35),
                    12:(-28,-22),13:(-18,-42),15:(28,32)}
        dx,dy=shifts.get(tag,(3,23))
    ax.annotate(str(tag),(point.real,point.imag),xytext=(dx,dy),textcoords='offset points',
                fontsize=12,color=color,ha='center',va='center',
                bbox={'boxstyle':'round,pad=.15','facecolor':'white','edgecolor':color,'linewidth':.6},
                arrowprops={'arrowstyle':'-','lw':.5,'color':color})
    return offscale


def legend_handles():
    handles=[Line2D([],[],color='.55',ls=':',label='smooth axis gluing'),
             Line2D([],[],color='#555555',ls='--',lw=2.3,marker='s',label='other root / cut'),
             Line2D([],[],color='#8064a2',ls='-.',marker='^',label='three-body threshold / cut')]
    handles += [Line2D([],[],color=c,lw=1.5,label=n+' lhc') for n,c in COLORS.items()]
    handles += [Line2D([],[],color='black',ls='-',marker='o',label='π: solid / circle'),
                Line2D([],[],color='black',ls=':',marker='D',label='η: dotted / diamond')]
    return handles


def markdown_key(index,keys,radius):
    lines=[f'## {NAMES[index]} chart','',
           f'Local quadrant–sheet disc: radius {radius:.2f} MeV. The origin is a regular point of this momentum chart.',
           'The ± images share one tag. Objects outside ±1100 MeV remain listed; deep OME endpoints have no plot arrow.',
           'Cut lanes are displaced by 18 MeV for readability; markers are exact. Scalar-moment loci only; projected strengths and threshold powers are not shown.',
           '', '| tag | object | k (MeV) | E (MeV) |','|---:|---|---:|---:|']
    for tag,label,z,E,off,color in sorted(keys):
        kval='0' if z==0 else f'$\\pm {abs(z.imag if z.imag else z.real):.2f}'+('i$' if z.imag else '$')
        lines.append(f'| {tag} | {label}'+(' (outside view)' if off else '')+f' | {kval} | {E:+.2f} |')
    return '\n'.join(lines)+'\n'


def individual_chart(index,filename):
    lim=1100
    fig,ax=plt.subplots(figsize=(8,8))
    fig.subplots_adjust(left=.13,right=.97,bottom=.19,top=.91)
    radius=local_sheet_disc(ax,index,lim)
    ax.axhline(0,color='.55',ls=':',lw=.8,zorder=-1)
    ax.axvline(0,color='.55',ls=':',lw=.8,zorder=-1)
    ax.scatter(0,0,s=50,facecolor='white',edgecolor='black',zorder=9)
    own_tag=next(tag for tag,(_,other) in enumerate(S.thresholds,1) if other==index)
    ax.annotate(f'{own_tag} own threshold\nregular root chart',(0,0),xytext=(420,-650),fontsize=11,
                arrowprops={'arrowstyle':'-','color':'.4','lw':.55,'shrinkA':2,'shrinkB':4})
    keys=[]
    for tag,(label,other) in enumerate(S.thresholds,1):
        if other==index:
            keys.append((tag,f'{label} own threshold — regular chart point',0j,S.channel(other).delta*1000,False,'#222222'))
            continue
        E=S.channel(other).delta*1000
        z=complex(mapped(E,index))
        for sign in (-1,1):
            lane(ax,[sign*z,sign*lim*(1j if z.imag else 1)],-9 if tag%2 else -27,'#555555',lw=2.3,ls='--')
        tagged_marker(ax,z,tag,'#444444','s',lim)
        keys.append((tag,f'{label} two-body root',z,E,False,'#444444'))
    for (pair,phi),E in three_body_thresholds(S).items():
        tag=4+list(three_body_thresholds(S)).index((pair,'pi'))//2+(3 if phi=='eta' else 0)
        z=complex(mapped(E*1000,index))
        off=tagged_marker(ax,z,tag,'#8064a2','^',lim)
        if not off:
            for sign in (-1,1):
                lane(ax,[sign*z,sign*lim],-48-18*((tag-4)%3),'#8064a2',lw=1.1,ls='-.')
        keys.append((tag,pair+('π' if phi=='pi' else 'η')+' three-body',z,E*1000,off,'#8064a2'))
    for j,row in enumerate(DATA['entries']):
        color=COLORS[row['transition']]
        E=row['roots'][0]['E_MeV'][0]
        z=complex(mapped(E,index))
        off=tagged_marker(ax,z,10+j,color,'o' if row['meson']=='pi' else 'D',lim)
        for segment in DATA['chart_cut_segments']:
            if segment['plane']!=index or segment['transition']!=row['transition'] or segment['meson']!=row['meson'] or not segment['is_cut']:
                continue
            values=np.array([segment['start_MeV'],segment['end_MeV']])
            values=np.where(abs(values)==1000,np.sign(values)*lim,values)
            zz=values*(1j if segment['axis']=='imag' else 1)
            double=round(segment['normalized_jump'])==2
            for shift in ((-4,4) if double else (0,)):
                lane(ax,zz,18*(j+1)+shift,color,lw=.85 if double else 1.25,ls='-' if row['meson']=='pi' else ':')
        keys.append((10+j,row['transition']+(' π' if row['meson']=='pi' else ' η')+' endpoint',z,E,off,color))
    ax.set(xlim=(-lim,lim),ylim=(-lim,lim),aspect='equal',xlabel=r'Re $k$ [MeV]',ylabel=r'Im $k$ [MeV]',title=NAMES[index]+' plane')
    ax.grid(alpha=.10)
    fig.legend(handles=legend_handles(),loc='lower center',ncol=3,fontsize=9,bbox_to_anchor=(.5,.015))
    save_figure(fig,filename)
    return markdown_key(index,keys,radius)


def zoom_chart():
    fig,ax=plt.subplots(figsize=(8,8))
    fig.subplots_adjust(left=.13,right=.97,bottom=.13,top=.91)
    lim=300
    local_sheet_disc(ax,1,lim)
    ax.axhline(0,color='.55',ls=':',lw=.8)
    ax.axvline(0,color='.55',ls=':',lw=.8)
    ax.scatter(0,0,s=50,facecolor='white',edgecolor='black',zorder=9)
    ax.annotate('own threshold\nregular root chart',(0,0),xytext=(85,-105),fontsize=11,
                arrowprops={'arrowstyle':'-','color':'.4','lw':.55})
    for j,row in enumerate(DATA['entries'][:2]):
        z=complex(mapped(row['roots'][0]['E_MeV'][0],1))
        for sign in (-1,1):
            lane(ax,[sign*z,sign*lim*1j],(j-.5)*6,COLORS['VV–VV'],ls='-' if row['meson']=='pi' else ':')
            ax.scatter(0,sign*z.imag,c=COLORS['VV–VV'],marker='o' if row['meson']=='pi' else 'D',s=45,zorder=8)
        ax.annotate('VV–VV '+('π' if row['meson']=='pi' else 'η'),(0,z.imag),xytext=(36,-4),textcoords='offset points',fontsize=12,color=COLORS['VV–VV'],arrowprops={'arrowstyle':'-','lw':.5,'color':COLORS['VV–VV']})
    ax.set(xlim=(-lim,lim),ylim=(-lim,lim),aspect='equal',xlabel=r'Re $k$ [MeV]',ylabel=r'Im $k$ [MeV]',title=NAMES[1]+' near-threshold zoom')
    ax.grid(alpha=.10)
    ax.legend(handles=[Line2D([],[],color=COLORS['VV–VV'],marker='o',ls='-',label='π circle'),Line2D([],[],color=COLORS['VV–VV'],marker='D',ls=':',label='η diamond')],loc='lower left',fontsize=9)
    save_figure(fig,'k-plane-BsBs-zoom.png')


(HERE/'figures').mkdir(exist_ok=True)
keys=['# Momentum-chart numbered keys','']
for index,filename in [(1,'k-plane-BsBs.png'),(5,'k-plane-BBs.png'),(6,'k-plane-BB.png')]:
    keys.append(individual_chart(index,filename))
(HERE/'data/k-plane-keys.md').write_text('\n'.join(keys))
zoom_chart()
