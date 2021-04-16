k=1
j=k+5

%
d=ST(:,:,(j-1)*24+1:j*24);
dd=nansum(d,3);
ddd=dd';
dddd=ddd(:,1:1744).*mask(:,1:1744);
%
%dddd=mst4_04us_20170813.*mask(1:875,:);
CDR(CDR<0)=NaN;
%

figure('Renderer', 'painters', 'Position', [100 100 700 800])


sLon = -134.98:0.04:-65.24;
sLat = 10.02:0.04:50;
t=dddd;
Z = flipud(t);
axesm('MapProjection', 'miller','GLineWidth',0.5, 'MeridianLabel', 'off','MLabelParallel'...
, 'south','ParallelLabel', 'on','MLineLocation', 10, 'PLineLocation', 5,...
'FFaceColor',[0.9 0.9 0.9],'MapLatLimit',[24 38],'MapLonLimit',[-102 -75],'fontweight','bold','fontsize',10);
hold on
states = geoshape(shaperead('usastatehi', 'UseGeoCoords', true));
hold on
axis([-130,-60,20,50])
pcolorm(sLat, sLon,Z);
geoshow(states,'facecolor','none','linewidth',1)
framem off;
gridm off;
hold on
tightmap;
% b=title (['(a) Stage IV']);
% b.FontSize=15
hold on
%b.FontWeight = 'bold'
hold on
textColor = 'white';
hold on
set(gca, 'color', [0.9, 0.9, 0.9])

cm = (colormap((jet(256))));
cm(1,:) = ones(1,3);
caxis([0 120])
colormap(cm);

colorbar off