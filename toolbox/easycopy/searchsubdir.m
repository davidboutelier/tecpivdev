function Outfiles=searchsubdir(baseDir,searchExpression,varargin)
% OUTFILES = SEARCHSUBDIR(BASEDIRECTORY,SEARCHEXPRESSION,varargin)
% search all subdirectories to find files in that match the search expression
% optional arguments: startdate, stopdate,
% searchsubdir(baseDir,searchExpression,startdate,stopdate)
% use blank, '' {} [] to skip an argument
% For example:
% stopdatesearch = searchsubdir('c:\users\','*.txt','','2017-04-30 00:00:00')
%
%-------------------------------------------------------------------------
% QUESTIONS, COMMENTS, FEEDBACK
% Michael Rowlands - v1.0 2017-05-24
% Engineering in the 21st century; Make It Easy !
% easineering@gmail.com
%-------------------------------------------------------------------------

if ispc
    type = 2; % 2 = system dir (fast)
    slsh = '\';
else
    type = 3; % 1 = standard matlab ls command for mac and xNix 
    slsh = '/';
end
%type = 3;

startdate = datenum(1900,1,1); % initialize defaults of variables
enddate = datenum(2099,1,1);
datesearch = 1;
listy= [];
exact = 0;
insens = 1;
nosubdir=0;

searchExpression = strrep(searchExpression,'\w','');

if not(strcmpi(baseDir(end),slsh))
    baseDir = [baseDir,slsh];
end

[baseDir,direxp] = dirwildcards(baseDir);

if nargin > 2
    startdate = varargin{1};
    if length(startdate) == 0 % if startdate is blank, go to default
        startdate = datenum(1900,1,1);
    end
end

if nargin > 3
    enddate = varargin{2};
    if length(enddate) == 0 % if startdate is blank, go to default
        enddate = datenum(2099,1,1);
    end
end

if nargin > 4
    exact = varargin{3};
end

if nargin > 5
    varg = varargin{4};
    insens = mod(varg,2);
    nosubdir = floor(varg/2);
    if length(insens)==0
        insens = 1;
        nosubdir = 0;
    end
end

% faster version
if type == 2
    searchy = strrep(searchExpression,'\w','');
    if strcmp(searchy(1),slsh)
        searchy(1) = [];
    end
    [srdir srfil srext] = fileparts(searchy);
    %dhtlogs = searchsubdir('\\SGMFP01\Group\Data\DHT Logs\','\w*.tdms',now - .5);
    % [~, q] = system('dir /s "\\SGMFP01\Group\Data\LASERLINC MONITORING\Batch\*line 16*.csv" ');
    % [~, q] = system('dir /s "\\SGMFP01\Group\Data\DHT Logs\*.tdms" ');  
    
    stringy = [baseDir,searchy];
    if nosubdir == 1      
        [~, q] = system(['dir "',stringy,'" ']);
    else
        [~, q] = system(['dir /s "',stringy,'" ']);
    end        
    b = strsplit(q,'\n');
    indx = 1;
    txt = char(b{indx});
    leny = length(b);
    ct = 0;
    
    while indx < leny
        while isempty(regexpi(txt,'Directory of')) && (indx<leny)
            indx = indx + 1;
            if indx< leny
                txt = char(b{indx});
            else
                break
            end
        end
        diry = [txt((regexpi(txt,'Directory of')+13):end),slsh];
        indx = indx + 1;
        if indx< leny
            txt = char(b{indx});
        else
            break
        end
        go = isempty(regexpi(txt,'Not Found'));
        while isempty(regexpi(txt(1:8),'   ')) & go
            datey = datenum(txt(1:20));
            filenm = txt(40:end);
            fullpath = [diry,filenm];
            fullpath = fullpath((regexp(fullpath,regexptranslate('wildcard',baseDir))+length(baseDir)):end);
%            sizey = str2num(txt(21:39));
            if not(isempty(regexpi(filenm,'_index'))) || not(isempty(regexpi(txt,'<DIR>'))) || datey<startdate || datey >enddate % clear unwanted entries
                % do nothing
            else
                dirchk = not(isempty(regexpi(diry,direxp)));
                if insens  % case-insensitive filename search
                    [a srch3 exty3] = fileparts(filenm);                    
                    [a srch4 exty4] = fileparts(searchy);
                    if length(exty3)
                        exty3(1)=[]; % get rid of the dot
                    end
                    if length(exty4)
                        exty4(1)=[]; % get rid of the dot
                    end
                    extchk = not(isempty(regexpi(exty3,['^',regexptranslate('wildcard',exty4),'$'])));
                    if regexpi(filenm,regexptranslate('wildcard',searchy)) & dirchk & ~exact & extchk
                        ct = ct +1;
                        listy{ct} = [diry,filenm];
                    else
                        if not(isempty(regexpi(filenm,[srfil,srext]))) & dirchk & exact
                            ct = ct +1;
                            listy{ct} = [diry,filenm];
                        end
                    end
                end
                if insens == 0  % case-sensitive filename search
                    if regexp(filenm,regexptranslate('wildcard',searchy)) & dirchk & ~exact
                        ct = ct +1;
                        listy{ct} = [diry,filenm];
                    else
                        if not(isempty(regexp(filenm,[srfil,srext]))) & dirchk & exact
                            ct = ct +1;
                            listy{ct} = [diry,filenm];
                        end
                    end
                end
            end
            indx = indx + 1;
            if indx< leny
                txt = char(b{indx});
            else
                break
            end
        end
    end
    Outfiles = listy;
end %type2

if type == 1
    dstr = dir(baseDir);%search current directory and put results in structure
    Outfiles = {};
    for II = 1:length(dstr)
        fullpath = [baseDir,dstr(II).name];
        searchy = [baseDir,direxp,regexptranslate('wildcard',searchExpression)];
        searchy2 = [baseDir,direxp,'.*',slsh,slsh,regexptranslate('wildcard',searchExpression)];        
%    if ~dstr(II).isdir && ~isempty(regexpi(dstr(II).name,searchExpression,'match'))
        try
            matchtest = ~dstr(II).isdir && ~isempty(regexpi(fullpath,searchy,'match'));
            matchtest = matchtest | (~dstr(II).isdir && ~isempty(regexpi(fullpath,searchy2,'match')));
            if ~dstr(II).isdir && ~isempty(regexpi(fullpath,searchy,'match'))
                if datesearch && (dstr(II).datenum >= startdate) && (dstr(II).datenum < enddate)
                    Outfiles{length(Outfiles)+1} = [baseDir,dstr(II).name];
                else if not(datesearch)
                        Outfiles{length(Outfiles)+1} = [baseDir,dstr(II).name];
                    end
                end
            end
        catch me
        end
        if and(dstr(II).isdir,and(~eq(dstr(II).name,'.'),~eq(dstr(II).name,'.')))
            Outfiles2 = searchsubdir([baseDir,dstr(II).name,slsh],searchExpression,startdate,enddate);
            Outfiles = [Outfiles, Outfiles2];
        end
    end
end % type 1

if type == 3
    dstr = ls(baseDir);%search current directory and put results in structure
    Outfiles = {};
    [len wid] = size(dstr);
    for II = 1:len
        dstrlist = strtrim(dstr(II,:));
        fullpath = [baseDir,dstrlist];
        searchy = [regexptranslate('wildcard',baseDir),regexptranslate('wildcard',searchExpression)];
        searchy2 = [regexptranslate('wildcard',baseDir),direxp,'.*',slsh,slsh,regexptranslate('wildcard',searchExpression)];        
%    if ~dstr(II).isdir && ~isempty(regexpi(dstr(II).name,searchExpression,'match'))
        try
            matchtest = ~exist(fullpath,'dir') && (~isempty(regexpi(fullpath,searchy,'match')) |~isempty(regexpi(fullpath,searchy2,'match')));
            if matchtest
                dstruct = dir(fullpath);
                if datesearch && (dstruct.datenum >= startdate) && (dstruct.datenum < enddate)
                    Outfiles{length(Outfiles)+1} = [fullpath];
                else if not(datesearch)
                        Outfiles{length(Outfiles)+1} = [fullpath];
                    end
                end
            end
        catch me
        end
        if ~strcmp(dstrlist,'.') & ~strcmp(dstrlist,'..')
            if ~isempty(regexpi([fullpath,slsh],[regexptranslate('wildcard',baseDir),direxp]))
                if exist(fullpath,'dir')
                    Outfiles2 = searchsubdir([baseDir,dstrlist,slsh],searchExpression,startdate,enddate);
                    Outfiles = [Outfiles, Outfiles2];
                end
            end
        end
    end
end % type 3