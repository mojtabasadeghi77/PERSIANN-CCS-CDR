clc;
clear all;
%cd '/zfs_data3/goesdata/B1_GPCPonly/adj_B1_daily_PCCSCDR_GPCPonly_fin'
cd '/zfs_data3/goesdata/PCCSCDRhr/adj_CPC_daily_PCCSCDRhr_GPCPonly_fin'
fn1='/zfs_data3/mojtabas/Junk/'
fn2='/zfs_data3/mojtabas/CCS_CDR_final_2003_CPC/'

for year =1
    years=year+2000
    for months=1:12
        months
        y=[];
        for days = 1:eomday(years, months);
             if exist(['PCCSCDRhr1d', num2str(year,'%02.f'), num2str(months,'%02.f'),num2str(days,'%02.f'),'.bin.gz'])
                 gunzip(['PCCSCDRhr1d', num2str(year,'%02.f'), num2str(months,'%02.f'),num2str(days,'%02.f'),'.bin.gz'],fn1)
                 t = fopen([fn1,'PCCSCDRhr1d', num2str(year,'%02.f'), num2str(months,'%02.f'),num2str(days,'%02.f'),'.bin']);
                 x=fread(t, [9000, 3000], 'float32');
                 x(x<0)=NaN;
                 y=cat(3,y,x);
             else
                 x=NaN(3000,9000);
                 y=cat(3,y,x);
                 tt=11
             end
        end 
    save([fn2, 'data_', num2str(years),num2str(months,'%02.f') 'CPC_CCS.mat'], 'y','-v7.3'); 
    which_dir = fn1;
    dinfo = dir(which_dir);
    dinfo([dinfo.isdir]) = [];   %skip directories
    filenames = fullfile(which_dir, {dinfo.name});
    delete( filenames{:} )
    end   
end
%%



