function [srclist destlist error] = buildlist(slist,dlist,sbase,dbase,filecode,replacecode)
%function [srclist destlist] = buildlist(srcfull,srclist,sbase,dest,filecode,replacecode)
%   Take 2 expressions, each with wildcards
%   and build an output cell array list of files and
%   destination files, for use with easycopy(srclist,destlist) command
%   replacecode sets the case-sensitivity for the file search and find-replace.
%
%   Use a blank to skip an argument and use the default settings; '' or []
%   or {}.
%   [srclist destlist] = buildlist(srcfull,'desktop\*.txt','','c:\users\joey\')   
%
%   This function takes the source files, then finds and replaces
%   text in a smart way to generate a desti)nation file list that the user
%   wants.
%
%   [srclist destlist] = buildlist('*.txt','*.csv')
%   srclist = {'c:\users\example.txt'  'c:\users\example2.txt'}
%   destlist = {'c:\users\example.csv'  'c:\users\example2.csv'}
%
%   See findreplaceplus.m for more details.
%
%   src = '*test?*.s4p'
%   dest = '!bTest?*.s4p'
%   
%   [srclist destlist] = buildlist(src,dest)
%   srclist = {
%   IL_test2.s4p
%   FEXT_Test4_try2.s4p
%   NExT_try3_TEST6.s4p
%   }
%   destlist = {
%   Test2_IL.s4p
%   Test4_FEXT_try2.s4p
%   Test6_NEXT_try3.s4p
%   }
%
%-------------------------------------------------------------------------
% QUESTIONS, COMMENTS, FEEDBACK
% Michael Rowlands - v1.0 2017-05-24
% Engineering in the 21st century; Make It Easy !
% easineering@gmail.com
%-------------------------------------------------------------------------


srclist{1}=[];
destlist{1}=[];
ferr = 0;
startdate = datenum(1900,1,1); % initialize defaults of variables
enddate = datenum(2099,1,1);

if ispc
    slsh = '\';
else
    slsh = '/';
end

if nargin < 5
    filecode = 1;
    replacecode = 'ignorecase';
end

slen = length(slist);
if isempty(dlist{1})
    dlen = 0;
else
    dlen = length(dlist);
end

if slen <1
    'ERROR: Source list cannot be empty.'
    error = 1;
    return
end

swchk= 0;  % does srclist have a wildcard?  if so, it can only have one entry
i = 1;
while ~swchk & i <= slen
    if not(isempty(regexpi(slist{i},'[*?]')))
        swchk = 1;
    end
    i = i + 1;
end

if (slen ~= dlen) & dlen ~=0 & ~swchk
    'ERROR: Source list and destination list do not have the same number of entries.'
    error = 1;
    return
end

if swchk & slen>1
    'ERROR: Source list with wildcards must have only one entry.'
    error = 1;
    return
end

dwchk = not(isempty(regexpi(dlist{1},'[*?]')));

if dwchk & dlen>1
    'ERROR: Destination list with wildcards must have only one entry.'
    error = 1;
    return
end

if dwchk & ~swchk
    'ERROR: Source and destination lists must both have wildcards.'
    error = 1;
    return
end

[dbaselen b] = size(dbase);
[sbaselen b] = size(sbase);


for i = 1:slen
    if strcmp(slist{i}(1),'\') | strcmp(slist{i}(2:3),':\') | strcmp(slist{i}(1),'/')
        slistcode = 1+2*swchk;
    else
        slistcode= 2+2*swchk;
    end
    
    if dlen==0
        dlistcode = 0;
    else
        if strcmp(dlist{i}(1),'\') | strcmp(dlist{i}(2:3),':\') | strcmp(dlist{i}(1),'/')
            dlistcode = 1+2*dwchk;
        else
            dlistcode = 2+2*dwchk;
        end
    end

    code = [num2str(slistcode),num2str(dlistcode),num2str(sbaselen),num2str(dbaselen)];
    
    switch code
        case {'1000','2000','3000','4000','1010','2010','3010','4010'}
            disp('ERROR: File cannot be copied onto itself.')
            error = 1;
            return
        case {'1100','1101','1110','1111'}
            srclist{i}=slist{i};
            destlist{i}=dlist{i};          
        case {'2001','2100','2101','2200','2201','4001','4100','4101','4200','4201','4300','4301','4400','4401'}
            disp('ERROR: Source base directory not defined.')
            error = 1;
            return
        case {'1001','1011'}
            srclist{i}=[slist{i}];
            [diry fily exty] = fileparts(srclist{i});
            destlist{i}=[dbase,fily,exty];
        case {'1200','1210'}
            srclist{i}=slist{i};
            [diry fily exty] = fileparts(srclist{i});
            destlist{i}=[diry,'\',dlist{i}];            
        case {'1201','1211'}
            srclist{i}=slist{i};
            destlist{i}=[dbase,dlist{i}];            
        case {'1300','1301','1310','1311','1400','1401','1410','1411','2300','2301','2310','2311','2400','2401','2410','2411'}
            disp('ERROR: If source has no wildcards, destination cannot have wildcards.')
            error = 1;
            return            
        case '2011'
            srclist{i}=[sbase,slist{i}];
            destlist{i}=[dbase,slist{i}];
        case {'2110','2111'}
            srclist{i}=[sbase,slist{i}];
            destlist{i}=[dlist{i}];            
        case '2210'
            srclist{i}=[sbase,slist{i}];
            [diry fily exty] = fileparts(srclist{i});
            destlist{i}=[diry,'\',dlist{i}];  % should it be sbase or diry? ??? use sbase, otherwise, user can make sdef work          
            destlist{i}=[sbase,dlist{i}];  % should it be sbase or diry? ??? use sbase, otherwise, user can make sdef work          
        case '2211'
            srclist{i}=[sbase,slist{i}];
            destlist{i}=[dbase,dlist{i}];            
        case {'3001','3011'}
            [diry fily exty] = fileparts(slist{i});
            srclist = searchsubdir(diry,[fily,exty],startdate,enddate,0,filecode);
            for ii = 1:length(srclist)
                [diry2 fily2 exty2] = fileparts(srclist{ii});
                diry3 = diry2((length(diry)+2):end);
                destlist{ii} = [dbase,diry3,'\',fily2,exty2];
            end
        case {'3100','3101','3110','3111'}
            [diry fily exty] = fileparts(slist{i});
            srclist = searchsubdir(diry,[fily,exty],startdate,enddate,0,filecode);
            if length(srclist) ~= length(dlist)
                'ERROR: Destination list is not the same length as the source list.'
                error = 1;
                return
            else
                destlist = dlist;
            end
        case {'3200','3210'}
            [diry fily exty] = fileparts(slist{i});
            srclist = searchsubdir(diry,[fily,exty],startdate,enddate,0,filecode);
%            if strcmp(diry(1:length(sbase)),sbase) % sbase is a subset of slist, use the delta to add to the destination path                  
            if length(srclist) ~= length(dlist)
                'ERROR: Destination list is not the same length as the source list.'
                error = 1;
                return
            else
                for ii = 1:length(srclist)
                    [diry2 fily2 exty2] = fileparts(srclist{ii});
                    
                    destlist{ii} = [diry2,'\',dlist{i}];
                end
            end
        case {'3201','3211'}
            [diry fily exty] = fileparts(slist{i});
            srclist = searchsubdir(diry,[fily,exty],startdate,enddate,0,filecode);
            if length(srclist) ~= length(dlist)
                'ERROR: Destination list is not the same length as the source list.'
                error = 1;
                return
            else
                for ii = 1:length(srclist)
                    destlist{ii} = [dbase,dlist{i}];
                end
            end
        case {'3300','3301','3310','3311'}
            [srclist destlist ferr] = findreplaceplus(slist{i},dlist{i},sbase,'',filecode,replacecode);
        case {'3400','3410'}
            [diry fily exty] = fileparts(slist{i});
            [srclist destlist ferr] = findreplaceplus(slist{i},[diry,'\',dlist{i}],sbase,'',filecode,replacecode);
        case {'3401','3411'}
            [srclist destlist ferr] = findreplaceplus(slist{i},[dbase,dlist{i}],sbase,dbase,filecode,replacecode);
        case {'4011'}
            [diry fily exty] = fileparts([sbase,slist{i}]);
            srclist = searchsubdir(diry,[fily,exty],startdate,enddate,0,filecode);
            for ii = 1:length(srclist)
                [dirs,fils,exts] = fileparts(srclist{ii});
                extra = dirs;
                extra(strfind(dirs,diry)+(0:(length(diry)-0))) = [];
                if not(isempty(extra))
                    extra = [extra,'\'];
                end
                destlist{ii} = [dbase,extra,fils,exts];
            end
        case {'4110','4111'}
            [diry fily exty] = fileparts([sbase,slist{i}]);
            srclist = searchsubdir(diry,[fily,exty],startdate,enddate,0,filecode);
            if length(srclist) ~= length(dlist)
                disp('ERROR: Destination list is not the same length as the source list.')
                error = 1;
                return
            else
                for ii = 1:length(srclist)
                    destlist{ii} = [dlist{ii}];
                end
            end
        case {'4210'}
            [diry fily exty] = fileparts([sbase,slist{i}]);
            srclist = searchsubdir(diry,[fily,exty],startdate,enddate,0,filecode);
            if length(srclist) ~= length(dlist)
                disp('ERROR: Destination list is not the same length as the source list.')
                error = 1;
                return
            else
                for ii = 1:length(srclist)
                    [dirs,fils,exts] = fileparts(srclist{ii});
                    [dird fild extd] = fileparts(dlist{ii});
                    extra = dirs;
                    extra(strfind(dirs,diry)+(0:(length(diry)-0))) = [];
                    if not(isempty(extra))
                        extra = [extra,'\'];
                    end
                    destlist{ii} = [dirs,'\',dlist{ii}];  % which way makes the most sense?
                    destlist{ii} = [diry,'\',dird,'\',extra,fild,extd];  % which way makes the most sense?
                end
            end
        case {'4211'}
            [diry fily exty] = fileparts([sbase,slist{i}]);
            srclist = searchsubdir(diry,[fily,exty],startdate,enddate,0,filecode);
            if length(srclist) ~= length(dlist)
                disp('ERROR: Destination list is not the same length as the source list.')
                error = 1;
                return
            else
                destlist{ii} = [dbase,dlist{ii}];
            end                
        case {'4310','4311'}
            [srclist destlist ferr] = findreplaceplus([sbase,slist{i}],dlist{i},sbase,dbase,filecode,replacecode);            
        case {'4410'}
            [diry fily exty] = fileparts([sbase,slist{i}]);
            [srclist destlist ferr] = findreplaceplus([sbase,slist{i}],[diry,'\',dlist{i}],sbase,dbase,filecode,replacecode);
        case {'4411'}
            [srclist destlist ferr] = findreplaceplus([sbase,slist{i}],[dbase,dlist{i}],sbase,dbase,filecode,replacecode);
                
    end
end

slistr = slist{1};
if strcmp(slistr(2:3),[':',slsh]) | strcmp(slistr(1),slsh) % absolute path
    % do nothing
else
    slistr = [sbase,slistr];
end

for srci = 1:length(srclist)
    if ~isempty(regexpi(slistr,'[*?]')) & ~isempty(regexpi([dbase,dlist{1}],'[*?]'))
        [srclist(srci) destlist(srci)] = findreplacedir(srclist(srci),destlist(srci),slistr,[dbase,dlist{1}]);
    end
end

if ferr
    error = 1;
else
    error =0;
end

end

