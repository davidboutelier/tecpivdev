function [slistout dlistout err] = findreplaceplus(findy,replace,sbase,dbase,filecode,replacecode)
%  function [ listout ] = findreplaceplus(findy,replace,sbase,dbase,filecode,replacecode)
%
%   This function takes the source files, then finds and replaces
%   text in a smart way to generate a destination file list that the use
%   wants.
%
%   [slistout dlistout] = buildlist('c:\users\*.txt','c:\users\joe\*.csv')
%
%   '!b' and '!e' are optional, special expressions that force the matched
%   source string to the beginning (!b) or the end (!e) of the destination
%   string.
%
%   For instance, the !b and !e featur was invented for this situation that
%   happened in the lab.
%
%   Measured s4p files were measured in the lab and named manually:
%   IL_test2.s4p
%   FEXT_Test4_try2.s4p
%   NEXT_try3_TEST6.s4p
%   (Notice the mix of upper and lower case letters, plus the "try.." notes
%   for some measurements. )
%
%   The tool that takes these files and makes a report, can only read
%   files named like this:
%   Test2_IL.s4p
%   Test4_FEXT_try2.s4p
%   Test6_NEXT_try3.s4p
%
%   There are hundreds of lab measurements with imperfect labels.
%   The user was looking for an easy way to rename all the files, so he
%   wrote this function.
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

err = 0;
strsize2 = 0;
slistout = [];
dlistout = [];
beginmove = 0;
endmove = 0;
startdate = datenum(1900,1,1); % initialize defaults of variables
enddate = datenum(2099,1,1);

[dirf filf extf] = fileparts(findy);
srclist = searchsubdir(dirf,[filf,extf],startdate,enddate,0,filecode);
[dird fild extd] = fileparts(replace);
% filf = [filf,'.']; % add end dot to the filename; good for certain wildcard searches
extf(1) = []; % remove the dot from the extension
% fild = [fild,'.']; % add end dot to the filename; good for certain wildcard searches
extd(1) = []; % remove the dot from the extension
% if not(isempty(regexpi(extf,'*')) &  isempty(regexpi(extf,'?')) & isempty(regexpi(extf,'!')) & isempty(regexpi(extd,'*')) &  isempty(regexpi(extd,'?')) & isempty(regexpi(extd,'!')))
%     cprintf('red','%s\n','ERROR:  Function does not support wildcards in the extension.')
%    err = 1;
%    return
% end

% smatchstr = strsplit([filf,extf],{'*'});
% smatchstr = strsplit([filf,'.'],{'*'});
% dmatchstr = strsplit([fild,extd],{'*','!b','!e'});

% smatchstr section
smatches = regexp(filf,'*');
if length(smatches)==0
    ssegs = 1;
else
    ssegs = 2*length(smatches)-1+(smatches(1)>1);
    if length(findy)>1
        ssegs = ssegs + (length(filf)>smatches(end));
    end
end

if ssegs == 1
    matchi(1) = 1;
    matchi(2) = length(filf);
end

if length(smatches)>0
    if smatches(1)==1;
        startstar = 1;
    else
        startstar = 0;
    end
end

if ssegs > 1
    if startstar
        matchi(1) = 1;
        matchi(2) = 1;
    else
        matchi(1) = 1;
        matchi(2) = smatches(1)-1;
    end
end

for i = 2:ssegs
    if (startstar & (mod(i,2)==0)) | (not(startstar) & mod(i,2))
%        matchi(2*i-1) = smatches(i-1-not(startstar))+1;
        matchi(2*i-1)= smatches(floor((i+startstar)/2))+1;
        if i == ssegs
            matchi(2*i) = length(filf);
        else
            matchi(2*i) = smatches(floor((i+startstar+1)/2))-1;
        end
    end
    if (startstar & mod(i,2)) | (not(startstar) & (mod(i,2)==0))
        matchi(2*i-1) = smatches(i-1);
        matchi(2*i) = smatches(i-1);
    end       
end 

for si = 1:ssegs
    smatchstr{si}=filf(matchi(si*2-1):matchi(si*2));
end
% end smatchstr section

% dmatchstr section
dmatches = regexp(fild,'*');
if length(dmatches)==0
    dsegs = 1;
else
    dsegs = 2*length(dmatches)-1+(dmatches(1)>1);
    if length(replace)>1
        dsegs = dsegs + (length(fild)>dmatches(end));
    end
end

if dsegs == 1
    matchd(1) = 1;
    matchd(2) = length(fild);
end

if length(dmatches)>0
    if dmatches(1)==1;
        startstar = 1;
    else
        startstar = 0;
    end
end

if dsegs > 1
    if startstar
        matchd(1) = 1;
        matchd(2) = 1;
    else
        matchd(1) = 1;
        matchd(2) = dmatches(1)-1;
    end
end

for i = 2:dsegs
    if (startstar & (mod(i,2)==0)) | (not(startstar) & mod(i,2))
        matchd(2*i-1)= dmatches(floor((i+startstar)/2))+1;
%        matchd(2*i-1) = dmatches(i-1-not(startstar))+1;
        if i == dsegs
            matchd(2*i) = length(fild);
        else
            matchd(2*i) = dmatches(floor((i+startstar+1)/2))-11;
        end
    end
    if (startstar & mod(i,2)) | (not(startstar) & (mod(i,2)==0))
        matchd(2*i-1) = dmatches(i-1);
        matchd(2*i) = dmatches(i-1);
    end
end

for si = 1:dsegs
    dmatchstr{si}=fild(matchd(si*2-1):matchd(si*2));
end
% end dmatchstr section


% dmatchstr = removeblanks(dmatchstr);
sstr = removeblanks(strsplit(filf,'*'));

% stars = regexpi([fily,exty],'*');
% qs = regexpi([fily,exty],'?');
% starts = regexpi([fily,exty],'!b');
% ends = regexpi([fily,exty],'!e');
% indexs_order = sorts([stars,starts,ends]);


destlist = srclist; % (definite, after wildcards)
% smatchstr = source match strings (after removing wildcards)
% dmatchstr = dest match strings (after removing wildcards)
% length(smatchstr) must match length(dmatchstr)

strsize = length(smatchstr)-length(dmatchstr);
if (strsize >= 0) & (strsize < 3)
    % consolidate lists
    sm = 0;
    dm = 0;
    breaker = 0;
    for smi = 1:length(smatchstr)
        for dmi = 1:length(dmatchstr)
            if isempty(regexp(smatchstr{smi},'*')) & isempty(regexp(dmatchstr{dmi},'*'))
                sm = smi;
                dm = dmi;
                breaker = 1;
            end
            if breaker
                break
            end
        end
        if breaker
            break
        end
    end
    for smi = 1:length(smatchstr)
        dmindex = dm - sm + smi;
        if (dmindex < 1) | (dmindex > length(dmatchstr))
            dmatchstr2{smi}='';
        else
            dmatchstr2(smi)=dmatchstr(dmindex);      
        end
    end
    dmatchstr = dmatchstr2;
end
% end consolidate lists

if strsize > 2
    cprintf('red','%s\n','ERROR: Replace expression does not have enough wildcards to match source.')
    disp('For example, try ')
    disp(' ')
    cprintf('*black','%s\n',upper([filf,extd]))
    disp(' ')
    disp('as the replace string.')
    disp(' ')
    disp(['actual find = ',filf,extf])
    disp(['actual replace = ',fild,extd])
    smatchstr
    dmatchstr
    err=1;
    return
else
    if strsize < 0    
        cprintf('red','%s\n','ERROR: Replace expression has more wildcards than source.')
        disp('For example, try ')
        disp(' ')
        cprintf('*black','%s\n',upper([filf,extd]))
        disp(' ')
        disp('as the replace string.')
        disp(' ')
        disp(['actual find = ',filf,extf])
        disp(['actual replace = ',fild,extd])
        smatchstr
        dmatchstr
        err=1;
        return    
    else
        strsize = 0;
        for ii = 1:length(srclist);
            beginstr = '';
            endstr = '';
            [dirs,fils,exts] = fileparts(srclist{ii});
 %           fils = [fils,'.'];
            exts(1)=[];
            extra = dirs;
            regindx = regexpi(dirs,regexptranslate('wildcard',dirf),'once','match');
            if ~strcmp(dirs,regindx)
                extra(strfind(dirs,regindx)+(0:(length(regindx)-0))) = [];
            else
%            if not(strcmp(dirs,dirf))
 %               extra(strfind(dirs,dirf)+(0:(length(dirf)-0))) = [];
%            else
                extra = '';
            end
            if not(isempty(extra))
                extra = [extra,'\'];
            end
            sname = fils;
            dname = sname;
            % add new code for ??? matches and extensions with wildcards
            extname = exts;
            [smatch3 dmatch3 strsize] = extractmatch(sname, filf, fild);
            [smext dmext strsizext] = extractmatch(exts, extf, extd);
            % add strsize return or note?
            smatchstr2 = smatch3;
            dmatchstr = dmatch3;
            % resolve ? wildcards for filename
            for i = 1:length(smatchstr2)
                qs = regexp(smatchstr2{i},'?');
                qd = regexp(dmatchstr{i},'?');
                if not(isempty(qs))
                    qstr = regexpi(sname,regexptranslate('wildcard',smatchstr2{i}),'match','once');
                    dstr = dmatchstr{i};
                    dstr(qd)=qstr(qs(1:length(qd)));
                    dmatchstr{i}=dstr;
                end
            end
            % resolve ? wildcards for extension
            for i = 1:length(smext)
                qxs = regexp(smext{i},'?');
                qxd = regexp(dmext{i},'?');
                if not(isempty(qxs))
                    qxstr = regexpi(exts,regexptranslate('wildcard',smext{i}),'match','once');
                    dxstr = dmext{i};
                    dxstr(qxd)=qxstr(qxs(1:length(qxd)));
                    dmext{i}=dxstr;
                end
            end
            
            switch strsize2
                case -1
                case 1
                case 0
                    for i = 1:length(smext)
                        smatchext = regexpi(exts,regexptranslate('wildcard',smext{i}),'match');
                        if isempty(smatchext)
                            smatchext = '';
                        else
                            smatchext = smatchext{1};
                        end
                        extname = regexprep(extname,smatchext,dmext{i},replacecode,'once');
                    end
                    extd = extname;

                    for i = 1:length(smatchstr2)
                        beginmove = 0;
                        endmove = 0;
                        smatch = regexpi(sname,regexptranslate('wildcard',smatchstr2{i}),'match');
                        if isempty(smatch)
                            smatch = '';
                        else
                            smatch = smatch{1};
                        end
                        dmatch = dmatchstr{i};
                        bangb = regexpi(dmatch,{'!b'});
                        bange = regexpi(dmatch,{'!e'});
                        if not(isempty(bangb{1}))
                            dmatch(bangb{1}+(0:1))=[];
                            beginmove=1;
                        end
                        if not(isempty(bange{1}))
                            dmatch(bange{1}+(0:1))=[];
                            endmove=1;
                        end
                        dmatch = regexprep(dmatch,'\.','\\\.');  % change the dot expression to \. so regexp can handle it
                        smatch = regexprep(smatch,'\.','\\\.');  % change the dot expression to \. so regexp can handle it
                        index = regexpi(dname,smatch);
                        if strcmp(dmatch,'*')
                            dmatch = smatch;
                        end
                        dname = regexprep(dname,smatch,dmatch,replacecode,'once');
                        if beginmove
                            if strcmp(dmatch(end),'.')
                                dname(index(1)+(0:(length(dmatch)-2)))=[];
                                beginstr = dmatch(1:(end-1));
                            else
                                dname(index(1)+(0:(length(dmatch)-1)))=[];
                                beginstr = dmatch;
                            end
                        end
                        if endmove
                            if strcmp(dmatch(end),'.')
                                dname(index(1)+(0:(length(dmatch)-2)))=[];
                                endstr = dmatch(1:(end-1));
                            else
                                dname(index(1)+(0:(length(dmatch)-1)))=[];
                                endstr = dmatch;
                            end
                        end
                    end
                    destlist{ii} = [dird,'\',extra,beginstr,dname(1:(end-1*0)),endstr,'.',extd];
            end
        end
    end
end

slistout = srclist;
dlistout = destlist;
% now, move !b and !e string to the beginning or end

