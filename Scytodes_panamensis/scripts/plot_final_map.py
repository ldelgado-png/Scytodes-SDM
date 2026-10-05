from pathlib import Path
import numpy as np
import pandas as pd
import rasterio
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patheffects as pe
import cartopy.crs as ccrs
from cartopy.io import shapereader
from matplotlib.lines import Line2D
from pyproj import Geod
BASE=Path(__file__).resolve().parent.parent
(BASE/'figures').mkdir(exist_ok=True)
with rasterio.open(BASE/'supplementary/Scytodes_panamensis_fc.LQ_rm.1.5_cloglog.tif') as src:
    data=src.read(1,masked=True); bounds=src.bounds
occ=pd.read_csv(BASE/'data/occurrences_combined.csv')
records=list(shapereader.Reader(shapereader.natural_earth('50m','cultural','admin_0_countries')).records())
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':10,'pdf.fonttype':42})
pc=ccrs.PlateCarree(); projection=ccrs.Mercator(central_longitude=-73)
fig=plt.figure(figsize=(12,6.8),facecolor='white')
ax=fig.add_axes([.065,.24,.88,.66],projection=projection)
ax.set_extent([-81.5,-64.8,7.5,13.1],crs=pc); ax.set_facecolor('#eaf1f5')
for rec in records:
    if rec.geometry.intersects(__import__('shapely').geometry.box(-82,7,-64,14)):
        ax.add_geometries([rec.geometry],pc,facecolor='#f1f0ea',edgecolor='#777777',linewidth=.55,zorder=1)
im=ax.imshow(data,extent=[bounds.left,bounds.right,bounds.bottom,bounds.top],origin='upper',transform=pc,cmap='viridis',vmin=.57,vmax=.81,interpolation='nearest',zorder=2)
for rec in records:
    if rec.geometry.intersects(__import__('shapely').geometry.box(-82,7,-64,14)):
        ax.add_geometries([rec.geometry],pc,facecolor='none',edgecolor='#575757',linewidth=.65,zorder=3)
styles=[('PA','o','#ffffff','GBIF · Panama (4 localities)'),('CO','^','#ec734a','New records · Colombia (7)'),('VE','D','#efc84a','New records · Venezuela, tentative (6)')]
for country,marker,color,label in styles:
    d=occ[occ.countryCode==country];ax.scatter(d.longitude,d.latitude,transform=pc,s=46,c=color,marker=marker,edgecolors='#172329',linewidths=.9,zorder=6)
for txt,x,y in [('PANAMA',-79.5,8.2),('COLOMBIA',-74.5,8.1),('VENEZUELA',-67.8,8.2)]:
    ax.text(x,y,txt,transform=pc,ha='center',fontsize=10,color='#475057',weight='bold',zorder=7,path_effects=[pe.withStroke(linewidth=2,foreground='white')])
ax.text(-73.7,12.5,'Caribbean Sea',transform=pc,ha='center',fontsize=12,fontstyle='italic',color='#597887')
gl=ax.gridlines(draw_labels=True,linewidth=.35,color='#7c919c',alpha=.4,xlocs=np.arange(-81,-64,3),ylocs=[8,10,12]);gl.top_labels=False;gl.right_labels=False;gl.xlabel_style={'size':9};gl.ylabel_style={'size':9}
ax.annotate('N',xy=(.964,.89),xytext=(.964,.70),xycoords='axes fraction',textcoords='axes fraction',ha='center',fontsize=12,weight='bold',arrowprops={'arrowstyle':'-|>','color':'#27333c','lw':1.4})
g=Geod(ellps='WGS84');x0,y0=-80.5,7.85;x1,y1,_=g.fwd(x0,y0,90,200000)
ax.plot([x0,x1],[y0,y0],transform=pc,color='#202d36',lw=2,zorder=8)
for x in [x0,x1]:ax.plot([x,x],[y0-.04,y0+.04],transform=pc,color='#202d36',lw=1,zorder=8)
ax.text((x0+x1)/2,y0+.1,'200 km',transform=pc,ha='center',fontsize=8,zorder=8)
fig.text(.065,.94,r'$\it{Scytodes\ panamensis}$',fontsize=19,color='#172a35')
fig.text(.065,.901,'Exploratory climatic suitability',fontsize=11,color='#53616c')
cax=fig.add_axes([.065,.153,.32,.024]);cb=fig.colorbar(im,cax=cax,orientation='horizontal',ticks=[.58,.62,.66,.70,.74,.78,.80]);cb.ax.tick_params(labelsize=8);cb.set_label('Cloglog model output',size=10)
handles=[Line2D([],[],linestyle='none',marker=m,markerfacecolor=c,markeredgecolor='#172329',markersize=7,label=l) for _,m,c,l in styles]
fig.legend(handles=handles,loc='lower left',bbox_to_anchor=(.47,.096),frameon=False,fontsize=9)
fig.text(.065,.043,'LQ · RM 1.5  |  14 occupied cells  |  Mean validation AUC 0.582 ± 0.152 SD',fontsize=9,color='#394954')
fig.text(.065,.016,'WorldClim 2.5′ · Natural Earth 1:50m · WGS84 / Mercator   |   Grey land: no prediction · Nearby occurrence points overlap.',fontsize=8,color='#64717b')
for ext in ['png','pdf','tif']:
    kw={'pil_kwargs':{'compression':'tiff_lzw'}} if ext=='tif' else {}
    fig.savefig(BASE/f'figures/Scytodes_panamensis_map.{ext}',dpi=400,facecolor='white',**kw)
print('Saved PNG, PDF and TIFF')
