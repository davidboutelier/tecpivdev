function [smatchout rmatchout strsize] = extractmatch(exactstring, searchstring, replacestring)
%function [smatchout dmatchout] = extractmatch(exactstring, searchstring, replacestring)
%
%   take an exact input string (exactstring) and the searchstring that
%   found that string, plus a replacestring
%
%   returns 2 lists:
%   1. smatch = a list of the strings that match the searchstring wildcards or
%   searchstring find string
%   2. rmatch = a list of the replacestrings that correspond to each of the smatch strings 
tic
smatches = regexp(searchstring,'*');
if length(smatches)==0
    ssegs = 1;
else
    ssegs = 2*length(smatches)-1+(smatches(1)>1);
    if length(searchstring)>1
        ssegs = ssegs + (length(searchstring)>smatches(end));
    end
end

if ssegs == 1
    matchi(1) = 1;
    matchi(2) = length(searchstring);
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
            matchi(2*i) = length(searchstring);
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
    smatchstr{si}=searchstring(matchi(si*2-1):matchi(si*2));
end

% dmatchstr section
dmatches = regexp(replacestring,'*');
if length(dmatches)==0
    dsegs = 1;
else
    dsegs = 2*length(dmatches)-1+(dmatches(1)>1);
    if length(replacestring)>1
        dsegs = dsegs + (length(replacestring)>dmatches(end));
    end
end

if dsegs == 1
    matchd(1) = 1;
    matchd(2) = length(replacestring);
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
            matchd(2*i) = length(replacestring);
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
    dmatchstr{si}=replacestring(matchd(si*2-1):matchd(si*2));
end
% end dmatchstr section

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
    % if no match for strings, match for stars
    if breaker == 0
        for smi = 1:length(smatchstr)
            for dmi = 1:length(dmatchstr)
                if not(isempty(regexp(smatchstr{smi},'*'))) & not(isempty(regexp(dmatchstr{dmi},'*')))
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

sstr = removeblanks(strsplit(searchstring,'*'));
sconvert = exactstring;
for ssi = 1:length(sstr)
    sconvert = regexprep(sconvert,regexptranslate('wildcard',sstr{ssi}),'@','ignorecase','once');
end
if strcmp(smatchstr{1},'*')
    sconv2 = strsplit(sconvert,'@');
else
    sconv2 = strsplit(sconvert,'@');
    if length(sconv2{1})==0 % remove first blank
        sconv2(1)=[];
    % sconv2 = removeblanks(strsplit(sconvert,'@'));
    end
end
ct = 0;
for i = 1:length(smatchstr)
    if strcmp(smatchstr{i},'*')
        ct = ct + 1;
        smatchstr2{i}=sconv2{ct};
        if strcmp(dmatchstr{i},'*')
            dmatchstr{i} = smatchstr2{i};
        else
            % dmatchstr{i} = ''; % else don't change it
        end
    else
        smatchstr2{i}=smatchstr{i};
    end
end
% END find star match

% setup ? wildcard
for i = 1:length(smatchstr)
    qs =  regexp(smatchstr{i},'?');
    qr =  regexp(dmatchstr{i},'?');
    if not(isempty(qs)) & not(isempty(qr))
        dchk = dmatchstr{i};
        schk = smatchstr2{i};
        dchk(qr) = schk(qs(1:length(qr)));
        dmatchstr{i} = dchk;
    end
end

smatchout = smatchstr2;
rmatchout = dmatchstr;