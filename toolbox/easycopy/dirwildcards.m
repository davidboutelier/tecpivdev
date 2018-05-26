function [basedir,dirsearch ] = dirwildcards(dirstring )
%  function [basedir,dirsearch ] = dirwildcards(dirstring )
%  extract base directory and directory search string from a directory
%  string
%
% EXAMPLE
% [basedir,dirsearch ] = dirwildcards('\\base\test??92\test3\')
% basedir = '\\base\'
% dirsearch = 'test??92\test3\'
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
    type = 1; % 1 = standard matlab dir command (slow) for mac and xNix 
    slsh = '/';
end

wc = 99999;
[dirtree,matches] = strsplit(dirstring,slsh);
for i = 1:length(dirtree)
    if not(isempty(regexpi(dirtree{i},'[*?]')))  % if it has a wildcard
        wc = i;
        break
    end
end

if wc < 99999  % if a wildcard was found, setup the base directory and the directory name search
    newbase = '';
    dirsearch = 1;
    for i = 1:(wc-1)
        newbase = [newbase,dirtree{i},matches{i}];
    end
    baseDir = newbase;
    direxp = dirtree{wc};
    for i = (wc+1):length(dirtree)
%        direxp = regexprep([direxp,matches{i-1},dirtree{i}],'?','.');
        if ispc
            direxp = regexprep([direxp,slsh,slsh,dirtree{i}],'?','.');
        else
            direxp = regexprep([direxp,slsh,dirtree{i}],'?','.');
        end
        direxp = regexprep(direxp,'*','.*');
    end
else
    baseDir = dirstring;
    direxp = regexptranslate('wildcard','*');
end

basedir = baseDir;
dirsearch = direxp;
    


