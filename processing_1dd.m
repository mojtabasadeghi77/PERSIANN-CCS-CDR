cd /zfs_data3/mojtabas/CCS_CDR_final_2003_CPC/
%cd /zfs_data3/mojtabas/CCS_CDR_final
for year=2001
    for months=2:12
        months
        y=[]
        load (['data_', num2str(year,'%04.f'), num2str(months,'%02.f'),'CPC_CCS.mat']); 
        CDR=[];
        for days=1:eomday(year, months)
            days
            data=y(:,:,days);
            data_1=resizem(data,[3000,1000],'bilinear');
            data_2=resizem(data_1,[1440,480],'bilinear');
            %data2=resizem(data_1,[360,120],'bilinear');
            CDR=cat(3,CDR,data_2');
        end
        save(['CCS_CDR_25km', num2str(year),num2str(months,'%02.f'),'.mat'],'CDR');
    end
end
%%
cd /zfs_data3/mojtabas/CCS_CDR_final_2003_CPC/
for year=2002
    year
    CDR_year=[];
    for months=1:12
        load (['CCS_CDR_25km', num2str(year),num2str(months,'%02.f'),'.mat']); 
        CDR_year=cat(3,CDR_year,CDR);
        save(['year_CCS_CDR', num2str(year),'.mat'],'CDR_year');
        CDR=[];
    end
end
%%
cd /zfs_data3/mojtabas/CCS_CDR_final
for years =1983:2002
    years
           load (['year_CCS_CDR', num2str(years),'.mat']); 
           date=1;
           for i=1:480
               for j=1:1440
                   matrix=CDR_year(i,j,:);
                   matrix(matrix<=0)=nan;
                   quant_mat(i,j,years-1982)=quantile(matrix,0.99);
               end
           end
           
end
save('quant_mat_1983_2002.mat','quant_mat')