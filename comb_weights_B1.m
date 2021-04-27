%***h* PERSIANN/comb_weights_B1.m
%
% NAME 
%     comb_weights_B1.m
%%
% PURPOSE
%     This matlab mfile function calulates the weighting factor grid from the monthly PERSIANN 2.5 deg
%       data and the monthly GPCP 2.5 deg file
%
% AUTHOR
%      Prof. Kuolin Hsu, Hamed Ashouri, Dan Braithwaite,
%	and Prof. Soroosh Sorooshian
%       At the Center for  Hydrometeorology and Remote
%       Sensing (CHRS) Department of Civil and Environmental Engineering
%       University of California, Irvine
%
% COPYRIGHT
%      THIS SOFTWARE AND ITS DOCUMENTATION ARE CONSIDERED TO BE IN THE PUBLIC
%      DOMAIN AND THUS ARE AVAILABLE FOR UNRESTRICTED PUBLIC USE. THEY ARE
%      FURNISHED "AS IS." THE AUTHORS, THE UNITED STATES GOVERNMENT, ITS
%      INSTRUMENTALITIES, OFFICERS, EMPLOYEES, AND AGENTS MAKE NO WARRANTY,
%      EXPRESS OR IMPLIED, AS TO THE USEFULNESS OF THE SOFTWARE AND
%      DOCUMENTATION FOR ANY PURPOSE. THEY ASSUME NO RESPONSIBILITY (1) FOR
%      THE USE OF THE SOFTWARE AND DOCUMENTATION; OR (2) TO PROVIDE TECHNICAL
%      SUPPORT TO USERS.  
%
% REVISION HISTORY
%      Creation date:   2/1/2011  
%      revised   6/1/2011 by dan braithwaite 
%      revised   1/30/2014 by Hamed Ashouri
%	    to use a maximum weight parameter mxWt=20
%	    to limit the bias correction to a reasonable range
%
% FILES
%      input files monthly PERSIANN at .25 deg and GPCP at 2.5 deg
%      output file is a weight factor file at 2.5 deg
%
% EXTERNALS
%      utility mfiles for loading/saving binary grids 
%
% SUBROUTINES
%      None
%
% REFERENCES
%      None for this code
%
% USAGE
%     called from do_bias_adj_B1.m
%      comb_weights_B1(YYMM)  
%      where YYMM is a 4-char string w/ 2-digit each for  year and mm
%
% ERROR CODES
%     None
%***  
%
%END HEADER

	function comb_weights_B1(yymm)

%% setting parameters
PG = 'GPCP/';
PD = 'bias_pers_mth/';
WOD= 'bias_weights/';
POD= 'bias_outpers/';
OD = 'bias_adjpers/';

Gifn	= [PG 'gpcp_m' yymm '.bin'];
MPifn 	= [PD 'B1accRR' yymm '.bin'];
MPCifn 	= [PD 'B1cntRR' yymm '.bin'];

dimG   = [72 144];
dimPlr  = [48 144];
dimPhr  = [480 1440];

meanPlr   = zeros(dimPlr) -1; % mean rainfall at 2.5-degree grid
nvalPlr = zeros(dimPlr); % number of pixels unsed in finding mean rainfall at 2.5 degree grid
adjPlr    = zeros(dimPlr); % adjusted PERSIANN rainfall at 2.5-degree grid

wtL = zeros(dimPlr);	% init to Nan  adjustment weights at low res.
wtL(:) = nan;
wtH = zeros(dimPhr);	% adjustment weights at high res.

%%%%% Load Data:
gpcp = loadbfn_b(Gifn,dimG,'float32')/24;
gpcp = gpcp(13:60,:); %extract 6060
gpcp(gpcp == -99999) = 0; % Getting rid of -99999. 
gpcp(gpcp < -4e+003) = 0; % Found this wierd number (-4.1666e+003) in gpcp data in July 1987.

pers  = loadbfn_l(MPifn, dimPhr, 'float32');

cntP = loadbfn_l(MPCifn, dimPhr, 'int16');

%%%%% transfer unit from mm/month -> mm/hr: consider the data count in one month
%!!!!!!    B1 data only has 8 grids (mm/hr) per day
%threshC = 30 * 24 * 0.50;	% threshold set at 70% of hourly data count in a month
threshC = 30 * 8 * 0.50;	% threshold set at 50% of (3)hourly data count in a month
rrpsn = zeros(dimPhr);
nn = find(cntP < threshC);
rrpsn(nn) = -1.0;
nn = find(cntP >= threshC);
rrpsn(nn) = pers(nn) ./ cntP(nn);

%% change PERSIANN data resolution from 0.25-degree to 2.5-degree
dimL(1) = dimPlr(1);
dimL(2) = dimPlr(2);

for i = 1: dimL(1)
    for j = 1: dimL(2)

	ist = (i-1) *10 +1;
	ien = i *10 ;
	jst = (j-1) *10 +1;
	jen = j *10 ;
	
	aa  = rrpsn(ist:ien, jst:jen);
	ff  = cntP(ist:ien, jst:jen);
	ind = find(aa>=0 & ff>threshC);
	if(~isempty(ind))
		meanPlr(i,j)    = mean(aa(ind));
		nvalPlr(i,j)  = size(ind,1);
	else
		meanPlr(i,j)    = -1;
		nvalPlr(i,j)  = 0;
	end
    end
end

%%%%% calculate the combination weights at 2.5 degree for each pixels
threshP=38; % 50 pixels at least in a total of 100 pixels

% 140117 set the min meanPlr
ind = find(nvalPlr >= threshP & meanPlr> 0 );
% thd_meanPlr = 0.0001;
% ind = find(nvalPlr >= threshP & meanPlr>= thd_meanPlr );
wtL(ind) = gpcp(ind) ./ meanPlr(ind);

% 140130 maximum limit for the weight factor
mxWt = 20;

if(mxWt > 0)
 ind = find(wtL > mxWt);
 wtL(ind) = mxWt;
end

% 140117 
ind = find(meanPlr ==0);
wtL(ind) = 0;
% ind = find(meanPlr < thd_meanPlr & meanPlr > 0);
% wtL(ind) = 1 ; % Bsically do no correction
% wtL(ind) = (gpcp(ind)+1) ./ (meanPlr(ind)+1) 

% testing threshold on meanPlr 131220
%ind = find(meanPlr > 0 & meanPlr < .001 );
% %wtL(ind) = (gpcp(ind)+1) ./ (meanPlr(ind)+1);

adjPlr = meanPlr .* wtL;

ind_L = find(meanPlr < 0);  % filter out NODATA using Orig
%size(ind_L)
%size(meanPlr)
adjPlr(ind_L) = -1;

%adding lots of extra NaN to -1 before all output

%% interpolation of combination weights to 0.25 degree scale
%[x, y]   = meshgrid(1:dimL(2), 1:dimL(1)); % HAT
%x=x-0.5; % HAT
%y=y-0.5; % HAT 
%z=wtL; % HAT
%z(ind_L) = nan; % HAT

%[xi, yi] = meshgrid(0.05:0.1:dimL(2), 0.05:0.1:dimL(1)); % HAT
%zi = interp2(x,y,z, xi, yi, 'linear'); % HAT

%GPCP  grid now (110513) using  lat long degrees
[x, y]   = meshgrid(1.25:2.5:360, 58.75:-2.5:-60);
%pers grid w/ latlong
[xi, yi] = meshgrid(.125:.25:360,59.875:-.25:-60);

z=wtL;
z(ind_L) = nan;

%adding outer ring for extrapolated points
gx = [zeros(size(x,1),1),x,ones(size(x,1),1)*360];
gx = [gx(1,:);gx ;gx(1,:)];

gy = [y(:,1)  , y , y(:,1)];
gy = [60*ones(1,size(gy,2));gy ; -60*ones(1,size(gy,2))];

m9 = -9;
gz = [m9(ones(size(z,1),1)) , z , m9(ones(size(z,1),1))];
gz = [m9(ones(1,size(gz,2))) ; gz ; m9(ones(1,size(gz,2)))];

%extrapolate gz points

%top row center
for i=2:size(gz,2)-1
  gz(1,i) = (gz(2,i-1) + gz(2,i+1))/2;
end

%bottom row center
lrow = size(gz,1);
nlrow = lrow-1;
for i=2:size(gz,2)-1
  gz(lrow,i) = (gz(nlrow,i-1) + gz(nlrow,i+1))/2;
end

lcol = size(gz,2);
nlcol = lcol-1;
for j=2:nlrow
   gz(j,1) = (gz(j,2) + gz(j,nlcol))/2;
   gz(j,lcol) = gz(j,1);
end

gz(1,1) = gz(2,1);
gz(1,lcol) = gz(2,1);

gz(lrow,1) = gz(nlrow,1);
gz(lrow,lcol) = gz(nlrow,1);

zi = interp2(gx,gy,gz, xi, yi, 'linear');


% need to limit zi to 0 to 4.0 % HAT
% was going negative here before
zi = setit(zi,find(zi < 0),0);

adjPhr = rrpsn .* zi;

ind_H = find(rrpsn < 0);  % filter out NODATA in and from Hres weights
zi(ind_H) = -1;
adjPhr(ind_H) = -1;

wtL(ind_L) = -1;   % filter nodata to Lres weights now

%% write adjusting weights
ofn = [WOD 'wwRatio' yymm '.bin'];
zi = setit(zi,nan,-1);
savebfn_l(ofn,zi,'float');

%%%%% write low reso PERSIANN (2.5-degree monthly)
ofn = [POD 'plr' yymm '.bin'];
meanPlr = setit(meanPlr,nan,-1);
savebfn_l(ofn,meanPlr,'float');

%%%%% write high reso PERSIANN (0.25-degree monthly)
ofn = [POD 'phr' yymm '.bin'];
rrpsn = setit(rrpsn,nan,-1);
savebfn_l(ofn,rrpsn,'float');

%%%%% write adjusted low reso PERSIANN (2.5-degree monthly)
ofn = [OD 'aplr' yymm '.bin'];
adjPlr = setit(adjPlr,nan,-1);
savebfn_l(ofn,adjPlr,'float');

%%%%% write adjusted high reso PERSIANN (0.25-degree monthly)
ofn = [OD 'aphr' yymm '.bin'];
adjPhr = setit(adjPhr,nan,-1);
savebfn_l(ofn,adjPhr,'float');

