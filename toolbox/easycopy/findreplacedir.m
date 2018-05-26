function [slistout dlistout err] = findreplacedir(srcdef,destdef,source,dest,filecode,replacecode)
%  function [ listout ] = findreplacedir(findy,replace,sbase,dbase,filecode,replacecode)
%
%   This function takes the source files, then finds and replaces
%   text in a smart way to generate a destination file list that the user
%   wants.
%  findreplacedir(srcdef{i},destlist{i},source,dest);
%  source, dest are single entries, findy, replace are lists
%-------------------------------------------------------------------------
% QUESTIONS, COMMENTS, FEEDBACK
% Michael Rowlands - v1.0 2017-05-24
% Engineering in the 21st century; Make It Easy !
% easineering@gmail.com
%-------------------------------------------------------------------------

filecode = 1;
replacecode = 'ignorecase';
[a b dextdef]=fileparts(destdef{1});
dextdef(1)=[];

if ispc
    slsh = '\';
else
    slsh = '/';
end


[dirf filf extf] = fileparts(source);
[dird fild extd] = fileparts(dest);

smatches = regexp(dirf,'*');
if length(smatches)==0
    ssegs = 1;
else
    ssegs = 2*length(smatches)-1+(smatches(1)>1);
    if length(source)>1
        ssegs = ssegs + (length(dirf)>smatches(end));
    end
end

if ssegs == 1
    matchi(1) = 1;
    matchi(2) = length(dirf);
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
            matchi(2*i) = length(dirf);
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
    smatchstr{si}=dirf(matchi(si*2-1):matchi(si*2));
end
% end smatchstr section

% dmatchstr section
dmatches = regexp(dird,'*');
if length(dmatches)==0
    dsegs = 1;
else
    dsegs = 2*length(dmatches)-1+(dmatches(1)>1);
    if length(dest)>1
        dsegs = dsegs + (length(dird)>dmatches(end));
    end
end

if dsegs == 1
    matchd(1) = 1;
    matchd(2) = length(dird);
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
            matchd(2*i) = length(dird);
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
    dmatchstr{si}=dird(matchd(si*2-1):matchd(si*2));
end
% end dmatchstr section

destlist = srcdef; % (definite, after wildcards)
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
        smatchstr
        dmatchstr
        err=1;
        return    
    else
        strsize = 0;
        for ii = 1:length(srcdef);
            beginstr = '';
            endstr = '';
            [dirs,fils,exts] = fileparts(srcdef{ii});
 %           fils = [fils,'.'];
            exts(1)=[];
            extra = dirs;
            regindx = regexpi(dirs,regexptranslate('wildcard',dirf),'once','match');
            if ~strcmp(dirs,regindx)
                extra(strfind(dirs,regindx)+(0:(length(regindx)-0))) = [];
            else
                extra = '';
            end
            if not(isempty(extra))
                extra = [extra,'\'];
            end
            sname = dirs;
            dname = sname;
            [smatch3 dmatch3 strsize] = extractmatch(sname, dirf, dird);
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
            strsize2 = 0;
            switch strsize2
                case -1
                case 1
                case 0
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
                        dname = regexprep(dname,regexptranslate('wildcard',smatch),regexptranslate('wildcard',dmatch),replacecode,'once');
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
                    destlist{ii} = [dname(1:(end-1*0)),endstr,slsh,fils,'.',dextdef];
            end
        end
    end
end

slistout = srcdef;
dlistout = destlist;
% now, move !b and !e string to the beginning or end

