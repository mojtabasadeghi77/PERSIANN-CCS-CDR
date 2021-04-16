states = geoshape(shaperead('7050046750.shp', 'UseGeoCoords', true));

axesm('MapProjection', 'miller','GLineWidth',0.5, 'MeridianLabel', 'on','MLabelParallel'...
, 'south','ParallelLabel', 'on','MLineLocation', 4, 'PLineLocation', 4,...
'FFaceColor',[1 1 1],'MapLatLimit',[27 37],'MapLonLimit',[-93 -87],'fontsize',8,'fontweight','bold');
hold on
framem on;
gridm off;
tightmap;
geoshow([states.Latitude], [states.Longitude],'Color','black','linewidth',1.5);
%
bordersm('continental us','color','k','linewidth',1)
