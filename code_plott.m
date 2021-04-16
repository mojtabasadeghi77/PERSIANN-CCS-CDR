load coast
%cd /zfs_data3/mojtabas/CCS_CDR_final
cd /zfs_data3/mojtabas/CCS_CDR_final_2003_CPC
%%
for years=2019
    for months=1:12
        load(['data_', num2str(years),num2str(months,'%02.f') 'CPC_CCS.mat']);
                parfor (days =1:eomday(years, months),10);
                h=figure(1);
                set(gcf, 'Position',  [100, 100, 800, 400]);
                set(h, 'Visible', 'off');
                b=y(:,:,days);
                a=b';
                temp_avrg_lgtrm1= a;
                tmp_chng_lgtrm = a;
                tmp_chng_lgtrm(:, 1:4500) = temp_avrg_lgtrm1(:, 4501:end);
                tmp_chng_lgtrm(:, 4501:end) = temp_avrg_lgtrm1(:, 1:4500);
                Z = flipud(tmp_chng_lgtrm);
                sLon = -180:0.04:179.97;
                sLat = -60:0.04:59.98;
                axesm('MapProjection', 'miller','GLineWidth',0.5, 'MeridianLabel', 'on','MLabelParallel'...
                , 'south','ParallelLabel', 'on','MLineLocation', 60, 'PLineLocation', 30,...
                'FFaceColor',[0.9 0.9 0.9],'MapLatLimit',[-60 60],'MapLonLimit',[-180 180],'fontsize',12,'fontweight','bold');
                pcolorm(sLat, sLon,Z);
                set(gca, 'color', [0.85, 0.85, 0.85])
                plotm(lat,long,'k');
                framem on;
                gridm on;     
                tightmap;
                cm = (colormap((jet(256))));
                cm(1,:) = ones(1,3);
                caxis([0 100]);
                colormap(cm);
                colorbar
                saveas(h,['CCS_CDR', num2str(years),num2str(months,'%02.f'),num2str(days,'%02.f'),'.png']);
                close all
                end
    end
end